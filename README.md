# DEMO DBT Project

Its a demo DBT project that I have built to explore the DBT hands on. I have used the public BQ dataset
`dbt-tutorial.jaffle_shop` as a source of this data modeling demo. I have created two BQ project - staging and production.

Staging is used to store dataset when the project is run from dev environment and Production is used to when 
this DBT project is running in a prod environment (i.e. a GCP hosted VM), scheduled as cronjob.


## Setup Local Dev Environment

### Prerequisites

- Must have [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed,
- Must have [uv](https://docs.astral.sh/uv/getting-started/installation/) installed,
- Must have [git](https://git-scm.com/downloads) installed,
- Must have access to the required gcloud projects,
- Sound knowledge on [Data Build Tool (dbt)](https://docs.getdbt.com/docs/introduction)

### Bigquery Permissions

User of this DBT project

- Need to have `Bigquery Job User` & `Bigquery Data Editor` permissions on the staging BQ project.
  

### Project Initialization

Run the following command(s) to initialize the environment in local system

```bash
gcloud auth login --update-adc
```

``` bash
source project-setup.sh
```


## Setup Prod Environment

1. [Install google cloud SDK in the VM](https://cloud.google.com/sdk/docs/install#deb)

2. [Install uv snap](https://snapcraft.io/install/astral-uv/ubuntu)

3. You may use the following cronjob,

```bash
   0 03 * * * /opt/project/run-dbt.sh >> /opt/project/logs/cron_$(date +\%F).log 2>&1
```

