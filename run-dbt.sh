#!/bin/bash
TARGET=${1:-"prod"}

function log() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") INFO $@"
}

source project-setup.sh "$TARGET" &&
dbt compile &&
dbt build

log "DBT RUN SUCCESSFUL"

