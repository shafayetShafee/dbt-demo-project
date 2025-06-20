#!/bin/bash

source init.sh &&
cd $DBT_PROJECT_DIR &&
dbt debug &&
dbt deps