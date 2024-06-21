#!/bin/bash

. /usr/local/bin/custom_metrics_shared.sh

instance_id="$1"
admin_url="$2"
username="$3"
password="$4"

metric_name="OpencastJobsQueued"

op_types="autotrim,composite,concat,demux,editor,encode,inspect,multiencode,process-smil,segment-video"
endpoint_url="${admin_url}/workflow/queuedJobCount?operations=${op_types}"

queued_jobs=$(curl -s --insecure --digest -u ${username}:${password} -H "X-Requested-Auth:Digest" $endpoint_url)

aws cloudwatch put-metric-data --region="$region" --namespace="$namespace" --dimensions="InstanceId=$instance_id" --metric-name="$metric_name" --value="$queued_jobs"
