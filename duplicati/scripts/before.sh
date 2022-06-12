#!/bin/bash

# https://github.com/duplicati/duplicati/blob/master/Duplicati/Library/Modules/Builtin/run-script-example.sh

echo "stop all Docker containers except duplicati"
docker stop $(docker ps -aq | grep -v $(docker ps -aq --filter="name=duplicati"))

# We want the exit code to always report success.
# For scripts that can abort execution, use the option
# --run-script-before-required = <filename> when running Duplicati
exit 0
