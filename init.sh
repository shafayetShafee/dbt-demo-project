#!/bin/bash
DEPLOYMENT=${1:-"dev"}
BQ_KEY_FILE=${2:-"keyfile.json"}
DBT_FOLDER=${3:-"jaffle_shop"}
VENV_PYTHON_VERSION=3.11.6

EXECUTION_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" > /dev/null 2>&1 && pwd )"
cd $EXECUTION_DIRECTORY

function log() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") INFO $@"
}

function warn() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") WARNING $@"
}

function error() {
    echo -e "$(date +"%Y-%m-%d T%H:%M:%S%z") ERROR $@"
    exit 1
}


case $DEPLOYMENT in
    prod)
        ROOT_PROJECT_DIR=/src
        DOT_ENV_FILE=$EXECUTION_DIRECTORY/.env.$DEPLOYMENT
        BQ_SERVICE_JSON=$ROOT_PROJECT_DIR/.gcloud/prod-$BQ_KEY_FILE
        GOOGLE_CLOUD_PROJECT="dbt-project-prod-463419"
        ;;
    dev)
        ROOT_PROJECT_DIR=$EXECUTION_DIRECTORY
        DOT_ENV_FILE=$EXECUTION_DIRECTORY/.env.$DEPLOYMENT
        BQ_SERVICE_JSON=$ROOT_PROJECT_DIR/.gcloud/dev-$BQ_KEY_FILE
        GOOGLE_CLOUD_PROJECT="dbt-project-463320"
        ;;
    *)
        error "Invalid deployment $DEPLOYMENT. It must be within [dev, prod]."
esac


DBT_PROJECT_DIR=$ROOT_PROJECT_DIR/$DBT_FOLDER
DBT_PROFILES_DIR=$DBT_PROJECT_DIR

UV_PYTHON_INSTALL_DIR=$ROOT_PROJECT_DIR/python
UV_CACHE_DIR=$ROOT_PROJECT_DIR/uv-cache


function get_gcloud_active_user() {
    case $DEPLOYMENT in
        dev)
            GCLOUD_ACTIVE_EMAIL=$(gcloud auth list --filter=status:ACTIVE --format="value(account)")
            DEVELOPER_NAME="${GCLOUD_ACTIVE_EMAIL%@*}"
            DEVELOPER_PREFIX="$(echo "$DEVELOPER_NAME" | tr "." "_" )"
            DBT_TARGET_PATH="target"
            TARGET="dev"
            log "Retrieved gcloud active user $DEVELOPER_NAME (from email:$GCLOUD_ACTIVE_EMAIL)."
            ;;
        prod)
            DEVELOPER_PREFIX="default_$DEPLOYMENT"
            DBT_TARGET_PATH=$DBT_PROJECT_DIR/target
            TARGET="prod"
            ;;
        *)
            error "Invalid deployment $DEPLOYMENT. It must be within [dev, prod]."
    esac
}


function create_dot_env() {
  if [ -f "$DOT_ENV_FILE" ]
    then
      warn "$DOT_ENV_FILE file already exists."
      warn "Overwriting the existing $DOT_ENV_FILE file."
  fi
  (
      echo "DEPLOYMENT=$DEPLOYMENT"
      echo "TARGET=$TARGET"
      echo "DBT_TARGET_PATH=$DBT_TARGET_PATH"
      echo "ROOT_PROJECT_DIR=$ROOT_PROJECT_DIR"
      echo "DBT_PROJECT_DIR=$DBT_PROJECT_DIR"
      echo "DBT_PROFILES_DIR=$DBT_PROFILES_DIR"
      echo "BQ_SERVICE_JSON=$BQ_SERVICE_JSON"
      echo "DEVELOPER_PREFIX=$DEVELOPER_PREFIX"
      echo "GOOGLE_CLOUD_PROJECT=$GOOGLE_CLOUD_PROJECT"
      echo "UV_PYTHON_INSTALL_DIR=$UV_PYTHON_INSTALL_DIR"
      echo "UV_CACHE_DIR=$UV_CACHE_DIR"
  ) > "$DOT_ENV_FILE"
  log "$DOT_ENV_FILE file created"
}


function create_python_venv() {

    log "Checking whether uv is installed or not"
    if command -v uv >/dev/null 2>&1; then
        log "uv is installed"
    else
        error "uv is not installed"
    fi

    log "Checking if Python $VENV_PYTHON_VERSION is already installed by uv"
    UV_PYTHON_VERSION_INSTALLED=$(uv find python --managed-python --show-version 2>/dev/null || true)

    if [[ "$UV_PYTHON_VERSION_INSTALLED" == "$VENV_PYTHON_VERSION" ]]; then
        log "Python $VENV_PYTHON_VERSION already installed by uv in $UV_PYTHON_INSTALL_DIR"
    else
        log "Installing Python $VENV_PYTHON_VERSION using uv"
        uv python install "$VENV_PYTHON_VERSION" --color auto || {
            error "Failed to install Python $VENV_PYTHON_VERSION using uv"
        }
        log "Python $VENV_PYTHON_VERSION installed successfully"
    fi

    if [ -d "$ROOT_PROJECT_DIR/venv" ]; then
        log "Directory $ROOT_PROJECT_DIR/venv exists."
    else
        log "Creating virtual environment for os:$OSTYPE"
        uv venv venv --python "$VENV_PYTHON_VERSION" \
                     --cache-dir "$UV_CACHE_DIR" \
                     --color auto \
                     --managed-python || {
            error "Failed to create virtual environment"
        }
        log "Virtual environment created"
    fi

    log "Activating virtual environment"
    source venv/bin/activate

    log "Virtual environment activated successfully, now installing requirements..."
    if [[ -f "requirements.txt" ]]; then
        uv pip install -r requirements.txt --color auto && 
        log "Requirements installed successfully" || {
            error "Failed to install requirements"
        }
    else
        error "No 'requirements.txt' file found, so not installing any dependencies"
    fi
}


get_gcloud_active_user &&
create_dot_env && {
    if [ -f "$DOT_ENV_FILE" ]
        then
        export $(xargs < "$DOT_ENV_FILE")
        log "Exported below mentioned environment variables.\n\n$(cat "$DOT_ENV_FILE")"
    else
        error "Failed to export environment variables. $DOT_ENV_FILE file does not exist."
    fi
} &&
create_python_venv &&
log "Congratulations, setup process completed."