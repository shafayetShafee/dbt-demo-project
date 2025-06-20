#!/bin/bash
TARGET=${1:-"dev"}

source init.sh "$TARGET" &&
cd $DBT_PROJECT_DIR &&
dbt debug &&
dbt deps