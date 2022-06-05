# Synapse

## Generating a configuration file
docker-compose run --rm -e SYNAPSE_SERVER_NAME=matrix.in4.vn -e SYNAPSE_REPORT_STATS=yes synapse generate

## Running synapse
docker-compose up -d

## Generating an (admin) user
docker exec -it synapse register_new_matrix_user http://192.168.1.4:19981 -c /data/homeserver.yaml