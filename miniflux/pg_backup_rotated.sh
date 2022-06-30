#!/bin/bash

###########################
####### LOAD CONFIG #######
###########################

while [ $# -gt 0 ]; do
        case $1 in
                -c)
                        CONFIG_FILE_PATH="$2"
                        shift 2
                        ;;
                *)
                        ${ECHO} "Unknown Option \"$1\"" 1>&2
                        exit 2
                        ;;
        esac
done

if [ -z $CONFIG_FILE_PATH ] ; then
        SCRIPTPATH=$(cd ${0%/*} && pwd -P)
        CONFIG_FILE_PATH="${SCRIPTPATH}/pg_backup.config"
fi

if [ ! -r ${CONFIG_FILE_PATH} ] ; then
        echo "Could not load config file from ${CONFIG_FILE_PATH}" 1>&2
        exit 1
fi

source "${CONFIG_FILE_PATH}"

###########################
#### PRE-BACKUP CHECKS ####
###########################

# Make sure we're running as the required backup user
if [ "$BACKUP_USER" != "" -a "$(id -un)" != "$BACKUP_USER" ] ; then
        echo "This script must be run as $BACKUP_USER. Exiting." 1>&2
        exit 1
fi


###########################
### INITIALISE DEFAULTS ###
###########################

if [ ! $HOSTNAME ]; then
        HOSTNAME="localhost"
fi;

###########################
#### START THE BACKUPS ####
###########################

function perform_backups()
{
        SUFFIX=$1
        FINAL_BACKUP_DIR=$BACKUP_DIR"`date +\%Y-\%m-\%d`$SUFFIX/"

        echo "Making backup directory in $FINAL_BACKUP_DIR"

        if ! mkdir -p $FINAL_BACKUP_DIR; then
                echo "Cannot create backup directory in $FINAL_BACKUP_DIR. Figure out permissions !" 1>&2
                exit 1;
        fi;

        ###########################
        ###### FULL BACKUPS #######
        ###########################

        echo -e "\n\nPerforming full backups"
        echo -e "--------------------------------------------\n"
        
        ###########################
        ### POSTGRES DATABASES ####
        ###########################

        QUERYCONTAINER=`docker ps -f name=postgres  --format '{{.Names}}'`
        
        if [ "$QUERYCONTAINER" ]; then

                FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn;"

                for DBCONTAINER in $QUERYCONTAINER;
                do
                        echo "CHECK-IN $DBCONTAINER"

                        if ! mkdir -p $FINAL_BACKUP_DIR/$DBCONTAINER; then
                                echo "Cannot create backup directory in $FINAL_BACKUP_DIR/$DBCONTAINER. Figure out permissions !" 1>&2
                                exit 1;
                        fi;

                        case $DBCONTAINER in

                                postgres) USERNAME="camunda";;

                        esac

                        for DATABASE in `docker exec $DBCONTAINER psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
                        do
                                if [ "$DATABASE" != "postgres" ];then
                                        echo "Backup of $DATABASE"
                                        if ! docker exec $DBCONTAINER pg_dump -Fp -C -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR$DBCONTAINER"/$DATABASE".sql.gz.in_progress; then
                                                echo "[!!ERROR!!] Failed to produce plain backup database $DATABASE" 1>&2
                                        else
                                                mv $FINAL_BACKUP_DIR$DBCONTAINER"/$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR$DBCONTAINER"/$DATABASE".sql.gz
                                        fi
                                fi;
                        done

                done

                echo -e "\nAll postgres databases backup have been completed successfully!"
         fi;
}

###########################
##### BACKUP ROTATION #####
###########################


###########################
##### MONTHLY BACKUPS #####
###########################


DAY_OF_MONTH=`date +%d`

if [ $DAY_OF_MONTH -eq 1 ];
then
        # Delete all expired monthly directories
        find $BACKUP_DIR -maxdepth 1 -name "*-monthly" -exec rm -rf '{}' ';'
                
        echo -e "\n\nPerforming Monthly backup"
        echo -e "--------------------------------------------\n"

        perform_backups "-monthly"

        exit 0;
fi


##########################
##### WEEKLY BACKUPS #####
##########################


DAY_OF_WEEK=`date +%u` #1-7 (Monday-Sunday)
EXPIRED_DAYS=`expr $((($WEEKS_TO_KEEP * 7) + 1))`

if [ $DAY_OF_WEEK = $DAY_OF_WEEK_TO_KEEP ];
then
        # Delete all expired weekly directories
        find $BACKUP_DIR -maxdepth 1 -mtime +$EXPIRED_DAYS -name "*-weekly" -exec rm -rf '{}' ';'
        
        echo -e "\n\nPerforming Weekly backup"
        echo -e "--------------------------------------------\n"
        
        perform_backups "-weekly"

        exit 0;
fi


#########################
##### DAILY BACKUPS #####
#########################

# Delete daily backups 7 days old or more

find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*-daily" -exec rm -rf '{}' ';'

perform_backups "-daily"