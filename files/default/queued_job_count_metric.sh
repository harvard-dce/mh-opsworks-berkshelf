#!/bin/bash

. /usr/local/bin/custom_metrics_shared.sh

instance_id="$1"
admin_hostname="$2"
username="$3"
password="$4"

metric_name="OpencastJobsQueued"

queued_jobs=$(curl -s --insecure --digest -u ${username}:${password} -H "X-Requested-Auth:Digest" "https://${admin_hostname}/workflow/queuedJobCount")

aws cloudwatch put-metric-data --region="$region" --namespace="$namespace" --dimensions="InstanceId=$instance_id" --metric-name="$metric_name" --value="$queued_jobs"
