# Synapse

## Set up Matrix on a sub-domain
docker run -it --rm -v db:/data -e SYNAPSE_SERVER_NAME=matrix.YOUR_DOMAIN -e SYNAPSE_REPORT_STATS=yes matrixdotorg/synapse:latest generate