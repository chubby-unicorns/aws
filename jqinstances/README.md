# jqinstances

## Intro

Bash script(s) using AWS CLI and JQ to retrieve information about:

- EC2 instances
- Attached EBS volumes
- RDS instances

Writes to csv files:

- EC2.csv
- RDS.csv

*E.g. use these as data sources in excel spreadsheet to estimate cost, etc.*

## Requirements

- Bash (tested on MacOS Catalina)
- AWS CLI - latest is best
- jq

## Usage

- Copy or create symlink to jqinstances.sh in relevant project folder, e.g. 
  - `ln -s ~/github/huevos/aws/jqinstances/jqinstances.sh jqinstances.sh`
- Edit variables if required
- Run `./jqinstances.sh`
  - You can use the argument `offline` to run the script subsequently, which excludes the AWS CLI commands.
