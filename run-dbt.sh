#!/bin/bash
TARGET=${1:-"prod"}

function log() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") INFO $*"
}

function error() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") ERROR $@"
    exit 1
}

EXECUTION_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

case $TARGET in
    prod)
        PROJECT_DIR="/opt/dbt-demo-project"
        LOG_DIR="$PROJECT_DIR/logs"
        ;;
    dev)
        PROJECT_DIR=$EXECUTION_DIRECTORY
        LOG_DIR="$PROJECT_DIR/logs"
        ;;
    *)
        error "Invalid deployment $DEPLOYMENT. It must be within [dev, prod]."
esac

cd "$PROJECT_DIR"

mkdir -p "$LOG_DIR"

log "Starting dbt pipeline with target '$TARGET'..."

{
    log "Running project setup..."
    source project-setup.sh "$TARGET"

    log "Running dbt compile..."
    dbt compile

    log "Generating docs..."
    dbt docs generate --no-compile

    log "Running dbt build..."
    dbt build

    log "DBT RUN SUCCESSFUL"
} >> "$LOG_DIR/run_dbt_$(date +%F).log" 2>&1
