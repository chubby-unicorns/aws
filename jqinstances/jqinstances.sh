#!/bin/bash
## GOALS:
# - output list of instances and attached volumes in CSV format, writing to STDOUT and OUTPUTFILE
# - use minimal aws cli calls (inefficient), use jq instead

# OFFLINE=1  # uncomment to force offline without cmd argument

## FILENAME & PATH VARIABLES
#
EC2OUTPUTFILE=EC2.csv
RDSOUTPUTFILE=RDS.csv

TMPFOLDER=/tmp # e.g. /tmp
INSTANCES=$TMPFOLDER/instances.txt
INSTANCESJSON=$TMPFOLDER/instances.json
DBINSTANCES=$TMPFOLDER/dbinstances.json
VOLUMES=$TMPFOLDER/volumes.json
TAGS=$TMPFOLDER/tags.json

## CHECK ARGUMENTS FOR "OFFLINE"
#
arguments=$1
if [[ $(echo $arguments | awk '{print toupper($0)}') == "OFFLINE" ]]; then OFFLINE=1; fi

## CHECK AWS CLI AND JQ ARE INSTALLED
#
if [[ ! -f $(which aws) ]]; then echo "Missing AWS CLI tools"; exit 1; fi
if [[ ! -f $(which jq) ]]; then echo "Missing jq"; exit 1; fi

## AWS CLI CALLS - run if not OFFLINE
#
AWSCLICALLS(){ 

    ## CHECK AWS CLI SESSION AND GET ACCOUNT ID
    #
    ACCOUNTID=$(aws sts get-caller-identity --query 'Account' --out text)
    if [[ $? != 0 ]]; then exit 0; fi

    ## GET ALL EC2 INSTANCES
    #
    aws ec2 describe-instances \
        --output json > $INSTANCESJSON

    ## GET ALL EC2 EBS VOLUMES
    #
    aws ec2 describe-volumes \
        --output json > $VOLUMES

    ## GET RDS INSTANCES
    #
    aws rds describe-db-instances \
        --output json > $DBINSTANCES

    ## GET TAGS
    #
    # aws resourcegroupstaggingapi get-resources > $TAGS  # GET ALL TAGS
    aws resourcegroupstaggingapi get-resources --resource-type-filters \
        rds:db \
        ec2:instance \
        --output json > $TAGS

}; if [[ ! -z $OFFLINE ]]; then echo -e "\n** RUNNING OFFLINE **\n"; else AWSCLICALLS; fi

## LOOP THE TASKS FOR ALL INSTANCES
#
function LOOPEC2INSTANCES(){
    echo -e "** Processing EC2 Instances: **"
    echo "Name,InstanceId,VolumeId,VolumeType,Iops,Size,Encrypted,AvailabilityZone,Device,Platform" > $EC2OUTPUTFILE
    for INSTANCE in $(jq -r '.Reservations[].Instances[].InstanceId' $INSTANCESJSON);
    do
        INSTANCE_NAME=$(jq -r --arg INSTANCE "$INSTANCE" \
                '.ResourceTagMappingList[] | select(.ResourceARN | contains($INSTANCE)) | .Tags[] | select(.Key | contains("Name")) | .Value' $TAGS)
        echo -e "\n   Instance : $INSTANCE_NAME ($INSTANCE)"
        PLATF=$(jq -r --arg INSTANCE "$INSTANCE" '.Reservations[].Instances[] | select(.InstanceId==$INSTANCE) | .Platform' $INSTANCESJSON)
        for VOL in $(jq -r --arg INSTANCE "$INSTANCE" '.Volumes[] | select(.Attachments[].InstanceId==$INSTANCE) | .VolumeId' $VOLUMES)
        do
            echo "     Volume : $VOL"
            read \
                TYPE \
                SIZE \
                IOPS \
                ENCR \
                AZ \
                DEVICE \
                    < <(echo $(jq -r --arg VOL "$VOL" '.Volumes[] | select(.VolumeId==$VOL) | .VolumeType, .Size, .Iops, .Encrypted, .AvailabilityZone, .Attachments[].Device' $VOLUMES))
            echo $INSTANCE_NAME,$INSTANCE,$VOL,$TYPE,$IOPS,$SIZE,$ENCR,$AZ,$DEVICE,$PLATF >> $EC2OUTPUTFILE
        done
    done
}

## RDS DB INSTANCES
#
function LOOPRDSINSTANCES(){
    echo -e "\n** Processing RDS Instances **\n"
    # echo "DBInstanceIdentifier,DBInstanceClass,Engine,DBName,AllocatedStorage,AvailabilityZone,MultiAZ,EngineVersion,PubliclyAccessible,StorageType,StorageEncrypted" > $RDSOUTPUTFILE
    ## smaller selection
    echo "DBInstanceIdentifier,DBInstanceClass,Engine,AllocatedStorage,MultiAZ,StorageType,StorageEncrypted" > $RDSOUTPUTFILE
    for DBII in $(jq -r '.DBInstances[] | select(.DBInstanceIdentifier) | .DBInstanceIdentifier' $DBINSTANCES);
    do
        echo -e "   Instance : $DBII"
        read \
            RDSDBInstanceClass \
            RDSEngine \
            RDSDBName \
            RDSAllocatedStorage \
            RDSAvailabilityZone \
            RDSMultiAZ \
            RDSEngineVersion \
            RDSPubliclyAccessible \
            RDSStorageType \
            RDSStorageEncrypted \
            < <(echo $(jq -r --arg DBII "$DBII" '.DBInstances[] | select (.DBInstanceIdentifier==$DBII) | .DBInstanceClass, .Engine, .DBName, .AllocatedStorage, .AvailabilityZone, .MultiAZ, .EngineVersion, .PubliclyAccessible, .StorageType, .StorageEncrypted' $DBINSTANCES))

        # echo "$DBII,$RDSDBInstanceClass,$RDSEngine,$RDSDBName,$RDSAllocatedStorage,$RDSAvailabilityZone,$RDSMultiAZ,$RDSEngineVersion,$RDSPubliclyAccessible,$RDSStorageType,$RDSStorageEncrypted" >> $RDSOUTPUTFILE
        ## smaller selection
        echo "$DBII,$RDSDBInstanceClass,$RDSEngine,$RDSAllocatedStorage,$RDSMultiAZ,$RDSStorageType,$RDSStorageEncrypted" >> $RDSOUTPUTFILE
    done
    echo " "
}

## EXECUTE LOOPS
#
LOOPEC2INSTANCES
LOOPRDSINSTANCES

