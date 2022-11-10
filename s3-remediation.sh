
#!/bin/bash

#

# 1. Scan all metadata for objects with duplicate keys

# 2. Repair all objects found with duplicate keys

# 3. Remove all non current objects added before the timestamp of the scan at step 1 above

# 4. Remove all deleteMarkers that exist on the bucket

#

# Author: cyrus.muraya@scality.com

# To remediate effects of S3C-3778

#

##### Change HERE Separated by a comma.

 

# Keep this line for the scheduled cron jobs.

BUCKETS="ca-rubrik-0"

 

# Use this line for individual bucket runs.

#BUCKETS="prd-abdw"

 

DATE=$(date +%Y-%m-%d)

##### Change HERE

LOG_DIR=/var/log/s3-remediation-scans/

 

##### Change HERE

s3_endpoint='obs-prd.allstate.com'

 

# ANY Stateless

bucketd_hostport='127.0.0.1:9000'

sproxyd_hostport='127.0.0.1:8181'

 

##### Change HERE

access_key='897TODZT0SJGPDO58EEO'

 

##### Change HERE

secret_key='yMjx5XOAKTf4WBXD7qf=L4AsY5w5bQTgrWppqOjx'

 

#

##### If left blank it will use today's date.

##### Change HERE IF you want to only delete versions and deletemarkers older than.

older_than_days=0

 

# Timestamp of now.

older_than_date=$(date +'%Y-%m-%dT%TZ' -d "${older_than_days} days ago")

 

# Create logging directory and status file variable

mkdir -p ${LOG_DIR}/${DATE}

REPORT_FILE=${LOG_DIR}/${DATE}/scan_status.log

LOG_FILE=${LOG_DIR}/${DATE}/s3-remediation-scan-${DATE}.log

 

cleanup_task(){

  # get the id of the container versions and test if they're runing

  CID=$(docker ps -a -q --filter "name=scality-s3-remediation")

  OID=$(docker ps -a -q --filter "status=exited" --filter "ancestor=zenko/s3utils:1.7.6")

  OID_RUNNING=$(docker ps -a -q --filter "status=running" --filter "ancestor=zenko/s3utils:1.7.6")

  if [[ -z "$CID" || -z "$OID_RUNNING" &&  -f /var/lock/subsys/s3_bucket_scan ]]

  then

    echo "Scan is not running. Cleaning up"

    rm -f /var/lock/subsys/s3_bucket_scan

  elif [[ -n "$CID" || -n "$OID_RUNNING" && -f /var/lock/subsys/s3_bucket_scan ]]

  then

    echo "Scan is already running. Exiting"

    exit 0

  elif [ -n  "$OID" ]

  then

    docker rm ${OID}

  else

    rm -f /var/lock/subsys/s3_bucket_scan

  fi

#  exit $?

}

 

cleanup_task

#Create a run file so we don't fire off multiple scans at the same time

touch /var/lock/subsys/s3_bucket_scan

 

# If the older_than_days variable is not set do not include it in the command.

if [ -z ${older_than_days} ]

then

    docker run -i --name scality-s3-remediation --net=host --rm registry.scality.com/s3utils/s3utils:1.9.1 /usr/bin/env UV_THREADPOOL_SIZE=16 S3_ENDPOINT=https://${s3_endpoint} ACCESS_KEY=${access_key} SECRET_KEY=${secret_key} BUCKETD_HOSTPORT=${bucketd_hostport} SPROXYD_HOSTPORT=${sproxyd_hostport} BUCKETS=${BUCKETS}  HTTPS_NO_VERIFY=1 ./checkAndCleanupNoncurrent.sh VERBOSE=1 | tee -a ${LOG_FILE}

else

   docker run -i --name scality-s3-remediation --net=host --rm registry.scality.com/s3utils/s3utils:1.9.1 /usr/bin/env UV_THREADPOOL_SIZE=16 S3_ENDPOINT=https://${s3_endpoint} ACCESS_KEY=${access_key} SECRET_KEY=${secret_key} BUCKETD_HOSTPORT=${bucketd_hostport} SPROXYD_HOSTPORT=${sproxyd_hostport} BUCKETS=${BUCKETS}  HTTPS_NO_VERIFY=1 OLDER_THAN=${older_than_date} VERBOSE=1 ./checkAndCleanupNoncurrent.sh | tee -a ${LOG_FILE}

fi

if [ $? -eq 0 ]

then

  KEYS_REPAIRED=$(grep repairDuplicateVersions ${LOG_FILE}| grep complete | jq -r '.objectsRepaired')

  FAILED_REPAIRS=$(grep repairDuplicateVersions ${LOG_FILE}| grep complete | jq -r '.objectsErrors')

  TIME_STARTED=$(grep "start scanning bucket" ${LOG_FILE} |head -1 | jq -r '.time/1000| strftime("%Y-%m-%d %H:%M:%S")')

  TIME_ENDED=$(grep "completed task for all buckets" ${LOG_FILE}|tail -1| jq -r '.time/1000| strftime("%Y-%m-%d %H:%M:%S")')

  echo "Scan for ${BUCKETS} started at ${TIME_STARTED} and ended at ${TIME_ENDED}" >> ${REPORT_FILE}

  echo "Objects repaired = ${KEYS_REPAIRED}, Repairs failed = ${FAILED_REPAIRS}" >> ${REPORT_FILE}

  IFS=',' read -r -a bucket_array <<< "$BUCKETS"

  for bucket in "${bucket_array[@]}"

  do

      total_objects=$(grep -A1  "completed task for bucket: ${bucket}" ${LOG_FILE}|tail -1 |  jq -r '.listed')

      deletes_triggered=$(grep -A1  "completed task for bucket: ${bucket}" ${LOG_FILE}|tail -1|  jq -r '.deletesTriggered')

      errors_triggered=$(grep -A1  "completed task for bucket: ${bucket}" ${LOG_FILE}| tail -1| jq -r '.errors')

      echo "Nothing to clean up in ${bucket}. Moving along" >> ${REPORT_FILE}

      echo "Deletion of deleteMarkers and non current objects in ${bucket} completed"  >> ${REPORT_FILE}

      echo "Total listed for ${bucket}: ${total_objects}"   >> ${REPORT_FILE}

      echo "Deletes triggered for ${bucket}: ${deletes_triggered}"   >> ${REPORT_FILE}

      echo "Errors while deleting ${bucket}: ${errors_triggered}"   >> ${REPORT_FILE}

  done

else

  echo "Bucket remediation for ${BUCKETS} failed. Please check ${LOG_FILE} for details" >> ${REPORT_FILE}

  cleanup_task

  exit $?

fi

 

# If we get here we have completed succesfully. Cleanup after ourselves

cleanup_task
