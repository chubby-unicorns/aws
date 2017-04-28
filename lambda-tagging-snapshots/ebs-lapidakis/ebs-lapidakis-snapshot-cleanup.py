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

#clean up old snapshots
    print "[LOG] Cleaning out old entries starting on " + str(cleanDate)
    for snap in ec2.snapshots.all():

        #veryify results have a value
        if snap.description.endswith("-automated"): 
            
            #Pull the snapshot date
            snapDate = snap.start_time.replace(tzinfo=None)
            if debugMode == True:
                print("[DEBUG] " + str(snapDate) +" vs " + str(cleanDate)) 
            
            #Compare the clean dates
            if cleanDate > snapDate:
                print("[INFO] Deleting: " + snap.id + " - From: " + str(snapDate))
                if debugMode != True:
                    try:
                        snapshot = snap.delete()
                    except:
                        #if we timeout because of a rate limit being exceeded, give it a rest of a few seconds
                        print("[INFO]: Waiting 5 Seconds for the API to Chill")
                        time.sleep(5)
                        snapshot = snap.delete()
                    print("[INFO] " + str(snapshot))