#!/bin/bash

# https://github.com/duplicati/duplicati/blob/master/Duplicati/Library/Modules/Builtin/run-script-example.sh

OPERATIONNAME=$DUPLICATI__OPERATIONNAME
 	
if [ "$OPERATIONNAME" == "Backup" ]
then
    echo "restart all exited Docker containers"
    docker start $(docker ps -aq --filter status=exited)
else
    exit 0
fi

# We want the exit code to always report success.
# For scripts that can abort execution, use the option
# --run-script-before-required = <filename> when running Duplicati
exit 0
