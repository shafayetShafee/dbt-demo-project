#!/bin/bash

EXECUTION_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
cd $EXECUTION_DIRECTORY

ROOT_PROJECT_DIR=$EXECUTION_DIRECTORY

rm -rf $ROOT_PROJECT_DIR/python &&
rm -rf $ROOT_PROJECT_DIR/venv &&
rm -rf $ROOT_PROJECT_DIR/uv-cache