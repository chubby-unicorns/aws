# Source: https://mike.lapidak.is/thoughts/tagging-and-snapshotting-with-lambda
import boto3
import logging
import datetime
import re
import time

#setup simple logging for INFO
logger = logging.getLogger()
# logger.setLevel(logging.INFO)
logger.setLevel(logging.ERROR)

#get the current region
session = boto3.session.Session()
session_region = session.region_name

#define the connection
ec2 = boto3.resource("ec2", region_name=session_region)

#set the snapshot removal offset
cleanDate = datetime.datetime.now()-datetime.timedelta(days=5)

#Set this to True if you don"t want the function to perform any actions
debugMode = False
# debugMode = True

def lambda_handler(event, context):
    
    if debugMode == True:
        print("-------DEBUG MODE----------")

#snapshop the instances
    for vol in ec2.volumes.filter(
        VolumeIds=[],
        Filters=[{
                "Name": "tag:Backups",
                "Values": [
                    "true",
                    "True",
                    "yes",
                    "Yes"
                ]}]):
        tempTags=[]
        print(tempTags)
        
        #Prepare Volume tags to be imported into the snapshot
        if vol.tags != None:
            for t in vol.tags:
                
                #pull the name tag
                if t["Key"] == "Name":
                    instanceName =  t["Value"]
                    tempTags.append(t)
                # else:
                #     tempTags.append(t)
        else:
            print("Issue retrieving tag")
            instanceName = "NoName"
            t["Key"] = "Name"
            t["Value"] = "Missing"
            tempTags.append(t)
        
        description = str(datetime.datetime.now()) + "-" + instanceName + "-" + vol.id + "-automated"
        
        if debugMode != True:
            #snapshot that server
            snapshot = ec2.create_snapshot(VolumeId=vol.id, Description=description)
            
            #write the tags to the snapshot
            tags = snapshot.create_tags(
                    Tags=tempTags
                )
            print("[LOG] " + str(snapshot))
            
        else:
            print("[DEBUG] " + str(tempTags))
            