# CHANGELOG

## TO BE RELEASED

# v5.1.0 - 6/12/2024

Opencast 15 configuration changes:

- Remove activemq
- Remove unused configuration (ldap, ca sync service)
- Update templates to latest
- Change ES index name (just so that we can rollback if needed)
- Change default captions flavor
 
# v5.0.7 - 3/7/2024 

- Adding tags to the crowdstrike config
- Bump activemq version to 5.15.16

# v5.0.6 - 2/2/2024

- Add cold archive configuration
 
# v5.0.5 - 12/11/2023

- /search/lucene* endpoint to be accessed only by admins 

# v5.0.4 - 10/26/2023

- `opencast.service` file should use path to the current deployment (vs hardcoded release path)

# v5.0.3 - 10/04/2023

- Clean pip cache just like we do for yum
- Removed the bits of the ua-harvester that were pulling zoom analytics

## v5.0.2 - 09/12/2023

- Upping the engage nginx `large_client_header_buffers` setting (from 4 * 8k to
  4 * 16k) to allow for big cookies and avoid HTTP 431/400 errors

## v5.0.1 - 09/08/2023

- Fixing again the MemoryUsed metric; first try didn't end up with the correct modification
- mysql backup cronjob wasn't sourcing anything that enabled the msyql software collection
- add missing SASL packages needed by postfix

## v5.0.0 - 08/21/2023

DEPLOY-86: update recipes to be compatible with RHEL7
    
Siginificant changes include:
    
- java 11 openjdk installed (instead of amazon corretto)
- installation and enabling of rhel7 "software collections" for python
  3.8 and mysql 5.7
- switch to using systemd service units for activemq and opencast
- update chef service blocks to explicitly use systemd
- setting selinux to permissive, meaning it will log warnings but not
  block anything
- creating a common function for pip installing python packages
- fixed issue where karaf pid/lock directories weren't getting created
  prior to OC start
- crowdstrike recipe needed to use `yum localinstall` to prevent errors
  when package was already installed (eg as part of the AMI)
- provide an updated `java.security` file to allow TLSv1.1 which OC
  needs for the jdbc connection handshake
- disable ssl on the jdbc connection from OC to MySQL:
  The RDS instance is on a private subnet and all communication between OC
  and the RDS resources takes place within the VPC, so disabling SSL is OK
- fixing a bug in the ganglia monitoring service definition file causing
  hung opsworks configure lifecycle events

## v4.4.6

* fix for missing engage id not being passed to `install_multitenancy_config` from the 
  `update-host-based-configurations` recipe and causing configure lifecycle event failures

## v4.4.5

* OPC-682: paella7 paths 
* Add engage host id to use in IC video urls
* Self-service standalone video editor role configuration

## v4.4.4

* Maven 3.8.8

## v4.4.3

* OPC-848: Immersive classroom url added to organization props.

## v4.4.2

* IC: OPC-851 `*.dcex.harvard.edu` cors support from Prod OC Engage

## v4.4.1

* IC: `*.dcex.harvard.edu` cors support, requires nginx update on engage
* IC: OC admin ability to reference a specific IC server (for mpId trim updates)

## v4.4.0

* Add stack name to org props in order to display it on the admin ui
* Fix for admin-ui series properties endpoint access 

## v4.3.1

* Hot-fix for maven 3.8.7 

## v4.3.0

* Add configuration for HarvardKey login.

## v4.2.0

* Remove legacy auth configuration
* Add thread id to log

## v4.1.1

* Remove uneccesary template

## v4.1.a

* Enable logging aws metrics
* Revert cleanup config for collection not used anymore (asset_aws_s3)

## v4.0.0

* Changes for Opencast 11.
* Bump version of Java and Maven.
* Admin node can use https. Needs a change in the default cluster config (Admin layer).
* Opencast configuration changes (elastic search, lti, active mq, watson, others)

## v3.2.0 - 05/26/2022

* DEPLOY-77: updated `buildspec.yml`, new artifact handling & notifications
* Fixing/adding a couple of metadata fields that foodcritic was complianing about
* oops. fixing the fix. Don't mess with those metadata version values, i guess.

## v3.1.1 - 04/29/2022

* Fix typo in deploy-engage recipe (`:presentation` vs `:admin`)

## v3.1.0 - 04/28/2022

* DEPLOY-76: allow use of prebuilt oc artifacts during deployment

## v3.0.6 - 04/27/2022

* Fix download url for maven

## v3.0.5 - 03/22/2022

* DEPLOY-75: fix `exec-dist-upgrade` recipe to use yum

## v3.0.4

* OPC-668: New cluster config param: production_management_email

## v3.0.3 - 02/07/2022

* OPC-649: New retract recordingAction endpoint GET mh_org access

## v3.0.2 - 02/04/2022

* DEPLOY-64: update path to public root cert bundle; ensure we're using postfix
* DEPLOY-64: ensure tls enabled at all points

## v3.0.1 - 01/20/2022

* DEPLOY-63: fixed path for elasticsearch options file

## V3.0.0 - 01/10/2022

  * DEPLOY-20: transition opencast opsworks deployment to amazon linux
    This commit rewrites a substantial number of our custom chef recipes to
    be compatible with Amazon Linux 2018.03, along with a few other changes
    here and there.

    At a high-level, the changes include:
    - standardizing on python3 and defining a common method of creating virtualenvs
    - removing all of the unused capture-agent-manager stuff
    - updating the package repos and keys for elasticsearch, et al
    - removing cloudwatch logs agent setup (we're using the opsworks
      baked-in functionality now)
    - removed newrelic installation and configuration
    - removed ubuntu-specific recipes
    - installing our own `run-one` script
    - properly implemented crowdstrike install recipes
    - removed a bunch of configuration references to 1x stuff
    - fixed bug in `dont_start_opencast_automatically` flag behavior
    - added an override mechanism for `dont_start_opencast_automatically`

## v2.27.1 - 11/01/2021

* OPC-637 Metasynch configurable distribution. Admin node.

## v2.26.0 - 09/29/2021

* *REQUIRES MANUAL RECIPE RUN* *REQUIRES EDITS TO CLUSTER CONFIG*
  MI-196: update syntax for esm registration command
  The `ubuntu_advantage_esm` block of the custom json must be updated from this:
  ```
  "ubuntu_advantage_esm": {
    "user": "...",
    "password": "..."
  },
  ```
  to this:
  ```
  "ubuntu_advantage_esm": {
    "token": "...",
  },
  ```
  For an existing cluster you must then execute the modified recipe:
  ```bash
  ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Engage,Utility,Storage,Analytics,Workers" recipes="oc-opsworks-recipes::enable-ubuntu-advantage-esm"
  ```

## v2.25.0

* OPC-554 Configuration for porta auth and porta migration services.

## v2.24.0

* OPC-554: Add configuration for porta series metadata update. (#244)

## v2.23.0

* Changed notification email

## v2.22.0

* OPC-596 Increase activemq memory (affects stage and prod).

## v2.21.0

* OPC-581 Configuration for the video export tool (send email with s3 bucket presigned urls).

## v2.20.1

* OPC-580: redirect http requests to engage to https when host is *.harvard.edu

## v2.19.0 - 12/17/2020

* MI-193: wipe `/root/.cache/pip/wheels` directory during cloudwatch log agent install
* OPC-577 remember-me bean for OC upstream security patches (companion OC patch)

## v2.18.0 - 11/02/2020

* OPC-568 Watson url from cluster config. Decrease check interval after expected job duration. (#235)

## v2.17.0 - 06/15/2020

* OPC-543 admin-ng series property rights for producers
* MI-187 don't let missing old ffmpeg fail the provisioning

## v2.16.3 - 04/27/2020

* OPC-498 update ffmpeg to 4.2

## v2.16.2 - 04/14/2020

* MI-185 use the aurora cluster's reader endpoint for the mysqldump

## v2.16.1 - 04/09/2020

* OPC-510 otherpubs helix value change email notification configurable on-off

## v2.15.0 - 3/20/2020

* OPC-496 On-demand zoom ingest: add configuration for zoom ingester endpoint.

## v2.14.0 - 1/24/2020

* OPC-446 Helix Googlesheets config for Otherservice
  Requires new cluster config params and update recipe

        helix_googlesheets, {
          enabled: <if false, the helix google sheets managed config is not created>,
          defaultduration_min: <no longer used, it's default dur of a helix pub>,
          token: <the service api, ask the dev team>,
          cred: <the old oauth2, ask the dev team>,
          helix_sheet_id: <the Helix Googledoc spreadsheet id of choice>
        }

## v2.13.0 - 1/21/2020

* OPC-357 HLS-VOD ffmpeg version and logging
* Requires ffmpeg push with ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::install-ffmpeg"

## v2.12.0 - 11/22/2019

* PSUPP-3145 playeroldRedirect auth for special test-local redirect page

## v2.11.0 - 10/10/2019

*  OPC-381-lamda-timeout-conf Search transcripts config

## v2.10.1 - 9/26/2019

* OPC-381 search-transcripts endpoint access update
* MI-126 adjust nfs availability cron and metric alarm to only trigger if two failures
  over two 60s periods to avoid false positives

## TO BE RELEASED

* OPC-357 HLS-VOD ffmpeg version and logging

## v2.10 - 8/22/2019

* OPC-359 search-transcripts
* OPC-139 LTI Oauth config change from Upstream
* OPC-334 many-embedded Added configuration to auth service
* MI-164: set nginx logrotate to only keep 30
* MI-171: nginx config reload needs to watch for changes to both the ssl key *and* cert

## v2.9 - 7/19/2019

* OPC-371 report a problem template updates

## v2.8 - 7/05/2019

* OPC-363 bug report feature
* OPC-344 Configuration for CA notification via CATracker (start/stop now)
   I.   Requires adding this to cluster configs custom_json:
       "capture_agent_sync": {
          "url": "https://<low level username>:<low level username's pasword>@catracker.<dev or prod catracker, preferably prod>.edu/tracker/notify/#{name}",
          "threshold": "180"
        },

  II. Required manually run recipe for OPC-344
     Run: ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="mh-opsworks-recipes::configure-activemq"
     To push template change:
     templates/default/activemq.xml.erb
                 <forwardTo>
                   <queue physicalName="SCHEDULER.Adminui" />
                   <queue physicalName="SCHEDULER.Externalapi" />
+                  <queue physicalName="SCHEDULER.CaptureAgentSync" />
                   <queue physicalName="SCHEDULER.Liveschedule" />
                 </forwardTo>

## v2.7.1 - 04/26/2019

* Fix for MI-162: ubuntu advantage recipe now included by a recipe that
  runs on *all* layer types

## v2.7.0 - 04/26/2019

* MI-162: new recipe to enable ubuntu advantage esm

## v2.6.0 - 04/23/2019

* OPC-340: producer permission for DCE stop-start scheduler endpoints

## v2.5.0 - 04/18/2019

* OPC-314: editor shortcut display config
* MI-160: analytics harvester install, don't create virtualenv if it exists

## v2.4.2 - 04/02/2019 (hotfix)

* increase execution timeout for the `awslogs-agent-setup.py` script to 300s

## v2.4.1 - 03/06/2019

* MI-159: fix `/etc/filename` hostname value

## v2.4.0 - 02/27/2019

* MI-156: Update engage nginx to allow requests from localhost for OpencastAvailable metric
* MI-157: Re-disable proxy buffering for the admin node's `/assets` path
* OPC-247: ibm watson creditials changes

## v2.3.0 - 02/13/2019

* MI-153: re-enable proxy buffering of upstream responses; ignore client abort

## v2.2.0

* MI-152: make instances failed and rds alarm names less misleading
* OPC-259 publisher and instructor name missing in email message body

## v2.1.0 - 01/25/2019

* OPC-226: restrict engage admin access to whitelisted hosts

## v2.0.0 - 01/11/2019

* MI-97: update mysql alarms for rds aurora cluster
* OPC-226: redirect http -> https in engage nginx configuration
* MI-125: rename maven cache archive to distinguish 5x vs 1x
* OPC-219: remove creation of `etc/opencast.conf` and allow enabling java debugging via `bin/setenv`
* MATT-2324: In 5x, it's Ok remove LTI process filter proxy workaround. Has companion OC 5x change.
* MI-117: recipe for installing the linux-aws kernel package
* MI-133: remove recipe for building enhanced networking kernel module
* updating some references to the "dont_start_matterhorn_automatically" flag
* MI-138: generate a cloudwatch metric based on Opencast's job load
* MI-140: cluster reset scripts now use correct solr indices path
* MI-143: fix for MYSQLServerAvailable metric generator
* MI-141: new workflow and job_load metrics

### notes merged from 5.x development

#### 11/02/2018

* ensure dist-upgrade runs with updated package repo and non-interactive mode
* mo-scaler now uses virtualenv to better manage/isolate python dependencies
* install additional network/io performance testing tools

#### 10/12/2018

* MI-114: cloudwatch metric for number of online workers

#### 09/27/2018

* OPC-155 Editor-shortcuts Waveform bigger encoding change
* OPC MATT-2406 only admin performs hearbeat checks config change
* OPC-59-metasynch Added ROLE_DCE_METASYNCH to metasynch endpoints

#### 09/10/2018

* MI-106: improvements to activemq install

#### 09/07/2018

* enable activemq install for all-in-one local clusters

#### 08/22/2018

* upgrade pip during moscaler install to handle improved `requirements.txt` dependency format

#### 08/10/2018

* activemq & nginx service fixes:
    * update to latest, stable activemq
    * fix for MI-86: activemq/opencast communication borked on first cluster start
    * reworking of nginx recipes to ensure config reloads happen on e.g. ssl cert updates

#### 08/02/2018

* cherry-picking a fix for the ua-harvester dependency installation
  note: this commit included some unrelated CHANGELOG updates

#### 07/23/2018

* fixing the enabling logic for the earlier newrelic changes

#### 07/18/2018

* only run the squid install recipe if external storage (i.e. zadara) is being used

#### 07/12/2018

* *REQUIRES MANUAL RECIPE RUN*
  install latest stable nginx & disable `proxy_request_buffering` for admin nginx to allow direct streaming of uploads.
  For an existing cluster you can either reboot the cluster, or, if that's not desired, the various nginx recipes must be run:
  ```bash
    ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="oc-opsworks-recipes::configure-nginx-proxy"
  ```
  ```bash
    ./bin/rake stack:commands:execute_recipes_on_layers layers="Engage" recipes="oc-opsworks-recipes::configure-engage-nginx-proxy"
  ```
  If you have an analytics node:
  ```bash
    ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="oc-opsworks-recipes::configure-elk-nginx-proxy"
  ```

#### 07/11/2018

* *REQUIRES MANUAL RECIPE RUN* *REQUIRES EDITS TO CLUSTER CONFIG*
  OPC-97: install newrelic via recipe.
  To enable newrelic in a cluster the custom json must include a block like:
  ```
    "newrelic": {
      "agent_version": "4.2.0",
      "admin": {
        "key": "xxxxx"
      },
      "engage": {
        "key": "xxxxx"
      },
    },
  ```
  For an existing cluster you must then execute the install recipe, either manually (command below) or by adding it to the layer's "setup" recipe run list in the cluster config and restarting the cluster instances:
  ```bash
    ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Engage" recipes="oc-opsworks-recipes::install-newrelic"
  ```
  **Then** you must also execute a deploy so that the opencast init scripts get updated as well:
  `./bin/rake deployment:redeploy_app opencast:restart`

### (end 5.x dev notes)

## v1.34.1 - 11/02/2018

* ensure the dist-upgrade runs with updated package repo && in non-interactive mode

## v1.34.0 - 10/29/2018

* OPC-149 Otherpubs config to combine Opencast pubs on pub listing

## v1.33.0 - 10/15/2018

* MI-114: cloudwatch metric for number of online workers

## v1.32.1 - 09/20/2018

* OPC-149, Otherpubs config to combine Opencast pubs on pub listing
* *REQUIRES MANUAL RECIPE RUN*
  set rds write iops alert threshold based on allocated storage & bump cpu usage alert to a more reasonable threshold

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="mh-opsworks-recipes::create-mysql-alarms"

## v1.32.0 - 08/18/2018

* LDAP integration (OPC-66).
* fix ua-harvester dependencies installation. No action required; only affects new clusters.
* *REQUIRES MANUAL_RECIPE RUN* - disable deprecated/insecure ssl protocols in nginx config
  For existing dev clusters manual recipe runs are not required; a cluster reboot will suffice as the nginx configs get updated during the opsworks "setup" phase.
  For clusters where it is not desirable to reboot, the following recipes must be run:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="mh-opsworks-recipes::configure-nginx-proxy"

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Engage" recipes="mh-opsworks-recipes::configure-engage-nginx-proxy"

  If the cluster has an Analytics node run the following as well:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="mh-opsworks-recipes::configure-elk-nginx-proxy"

## v1.31.1 - 04/19/2018

* *REQUIRES MANUAL _RECIPE RUN*
  updated loggly TLS certificate

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Workers,Engage" recipes="mh-opsworks-recipes::rsyslog-to-loggly"

## v1.31.0 - 3/05/2018

* ruby gem version revert because CI requires a different version that we use to build in production (security issue not relevant because it's for Travis CI)
* MATT-2406 limit service checking to just be from the service dispatcher to reduce unnecessary work and network traffic from the workers and engage nodes

## v1.30.0 - 1/12/2018

* 'yajl-ruby' gem version update to address security vulnerability
* added `buildspec.yml` file to allow automated CodeBuild builds. See the `harvard-dce/mh-opsworks-builder` project.
* pinned 'mixlib-archive' gem to previous version because of broken release

## v1.29.0 - 10/26/2017

* *REQUIRES MANUAL RECIPE RUN*
  Update useraction harvester & elasticsearch recipes for new, combined zoom + useraction analytics harvester

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="mh-opsworks-recipes::install-ua-harvester"

## v1.28.0 - 10/06/2017

* MATT-2464 nginx error log to INFO level for fileupload debugging

## v1.27.0 - 09/25/2017

* create cloudwatch log group for utility node's squid logs
* *REQUIRES MANUAL RECIPE RUNS*
  MI-74: nginx config performance improvements

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Workers" recipes="mh-opsworks-recipes::configure-nginx-proxy"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Engage" recipes="mh-opsworks-recipes::configure-engage-nginx-proxy"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="mh-opsworks-recipes::configure-elk-nginx-proxy"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Utility" recipes="mh-opsworks-recipes::configure-capture-agent-manager-nginx-proxy"

* *REQUIRES MANUAL RECIPE RUN*
  MI-73: recipe and script to pull capture agent logs w/ rsync, push to cloudwatch

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Utility" recipes="mh-opsworks-recipes::configure-capture-agent-cwlogs"

## v1.26.0 - 08/24/2017

* Allow exit status of '255' on cloudwatch log group creation to get rid of errors due to ResourceAlreadyExistsException
* cloudwatch logs agent install requires python-dev package
* refactor of moscaler install to allow separate recipes for creating/removing cron_d resources.
  this is to facilitate moscaler pause/resume rake tasks in `mh-opsworks`.

## v1.25.0 - 08/17/2017

* copy dce-config encodings engage-image.properties

## v1.24.0 - 08/10/2017

* add new recipe for executing `apt-get dist-upgrade` to facilitate kernel package updates
* update to latest recommended version of ixgbevf enhanced networking driver
* MATT-2355: added deployment config property for enabling/disabling workspace cleanup
* MATT-2388: spring config changes related to social annotations reports
* don't install yourkit by default on any nodes

## v1.23.1 - 07/25/2017

* don't install yourkit on non-mh nodes
* *REQUIRES MANUAL RECIPE RUN*
  bump evaluation period from 5m to 10m on RDS cpu and queue depth alarms. These metrics are occasionally experiencing short (<= 5m) spikes which appear to be benign but are triggering the alarms.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="mh-opsworks-recipes::create-mysql-alarms"

## v1.23.0 - 05/18/2017

* redirect output from MH start-on-boot cron entry to syslog to prevent
  unnecessary emails
* Allow enabling of G1 Garbage Collection method and YourKit profiler agent. Both are off by default. To enable, add either/both of the following attributes respectively to the cluster config's custom json:

```
    ...
    "enable_G1GC": true,
    ...
    "enable_yourkit_agent": true,
    ...
```
* set JVM `-Xxms` value based on ratio to`-Xxmx` depending on node type
* fetch `awslogs-agent-setup.py` cloudwatch logs setup script from shared assets bucket to ensure working/tested version

# v1.22.0 - 04/21/2017

* MI-63: remove nodejs install recipe as it is no longer needed
* *REQUIRES EDITS TO CLUSTER CONFIG*
  MI-62: create cron entry to sync ibm watson transcript results to s3. Prior to deployment, the `custom_json` block in cluster config should be updated with the name of the target s3 bucket:

        "ibm_watson_transcript_sync_bucket_name": "dce-ibm-watson-transcripts"

## v1.21.2-hotfix - 03/13/2017

* hotfix to address nginx proxy config mixup. The previous manual recipe run instructions should have been:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="mh-opsworks-recipes::configure-nginx-proxy"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Engage" recipes="mh-opsworks-recipes::configure-engage-nginx-proxy"

## v1.21.1 - 03/10/2017

* *REQUIRES MANUAL RECIPE RUN* Add $request_time value to nginx access log events
  Manual recipe run should come after deploy and an `update_chef_recipes`.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Engage" recipes="mh-opsworks-recipes::configure-nginx-proxy"

## v1.21.0 - 02/13/2017

* MATT-2231 login for annots summary path

## v1.20.0 - 02/06/2017

* MATT-1929 Create inbox for republish with re-trimming.

## v1.19.0 - 01/30/2017

* MATT-2245 Enable DCE annot property endpoint
* *REQUIRES EDITS TO CLUSTER CONFIG*
  include auth key when deploying mh auth properties file. `auth_key` value must be
  added to prod cluster config prior to deployment.

## v1.18.0 - 01/19/2017

* *REQUIRES EDITS TO EXISTING CLUSTER CONFIG*
* MATT-2046 Enable the vanilla Opencast LTI endpoint, requires new lit_oauth custom_json
* replace with the iCommons token from the private file (or create a new one from the iCommons APi webpage)
* replace with the consumerkey and shared secret from the private file
"stack": {
    "chef": {
    "custom_json": {
      "icommons_api_token": "replace-with-an-icommons-api-token-or-manually-create-series-mappings",
      "lti_oauth": {
        "consumerkey": "dce_lti_oauth_consumer_key",
        "sharedsecret": "dce_lti_oauth_sharedsecret"
      },
    ...

## v1.17.0 - 01/10/2017

* update CA hack: 53chur-l01 now points to new prod akami stream id (same as byerly)
* skip cloudwatch log setup for local clusters; fix rsyslog restart (MATT-2238)
* *REQUIRES MANUAL RECIPE RUN* Crowdstrike falcon host installation.
  The following command is an example of what would be run on the prod cluster. For dev clusters,
  adjust the `layers` list according to what nodes are present.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Engage,Utility,Storage,Analytics" recipes="oc-opsworks-recipes::install-crowdstrike"

## v1.16.0 - 12/8/2016

* *REQUIRES EDITS TO EXISTING CLUSTER CONFIG*
  Update the prod DNS certificate, see Confluence release notes
* added additional packages needed to compile mo-scaler required python packages
* Force reinstallation of elasticsearch plugins to avoid version mismatches.

## 1.15.0 - 11/18/2016

* *REQUIRES EDITS TO CLUSTER CONFIG*
  Configuration for the new Matterhorn ibm watson transcription service (service credentials).
* Changed location of temporary zip files to Zadara to avoid cross-device link errors. Zip operations are executed when republishing and failing a workflow.
* MATT-2215 add threshold config params to log connection durations in hudce-auth and leg-otherpubs (sys web msg)
* *REQUIRES MANUAL RECIPE RUN*
  Enable dynamic scripting in `elasticsearch.yml`

## 1.14.1 - 11/03/2016

* add `retries` to setting of cloudwatch log retention to avoid race condition
  when previous log group creation is still processing

## 1.14.0 - 10/28/2016

* *REQUIRES EDITS TO CLUSTER CONFIG*
  Refactoring of analytics node recipes:
    * move `install-ua-harvester` to `setup` list (after `install-elasticsearch`)
    * remove `configure-logstash-kibana` from `configure` list
    * add `configure-ua-harvester` to `configure` list
* *REQUIRES MANUAL RECIPE RUN*
  Adding redis service to analytics node for useraction harvest caching of episode data

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="oc-opsworks-recipes::install-ua-harvester"

## 1.13.0 - 10/20/2016

* explicitly set the `$HOME` env variable when pip-installing the ca manager dependencies.
* remove submodule init during Matterhorn code deploy (MATT-2173)
* update CA hack: byerly-013 now points to new prod akami stream id
* *REQUIRES EDITS TO CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUN*
  New recipe, `install-cwlogs`, that installs and configures the AWS Cloudwatch Log Agent.
  `mh-opsworks-recipe::install-cwlogs` should be added to the `setup` list of the
  Admin, Engage and Workers (and Analytics/Utility, if present) layers.

  Manual recipe runs should come after any MH release/deploy and an `update_chef_recipes`.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Engage,Workers" recipes="oc-opsworks-recipes::install-cwlogs"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="oc-opsworks-recipes::install-cwlogs,oc-opsworks-recipes::install-elasticsearch,oc-opsworks-recipes::install-kibana"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Utility" recipes="oc-opsworks-recipes::install-cwlogs,oc-opsworks-recipes::install-capture-agent-manager,oc-opsworks-recipes::configure-capture-agent-manager-nginx-proxy"

## 1.12.0 - 10/7/2016

* Akamai account limit hack. See MATT-2182.

* *REQUIRES MANUAL CHEF RECIPE RUN*
  Add new custom metric script for feeding jvm stats to cloudwatch.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::install-custom-metrics"

* *REQUIRES MANUAL CHEF RECIPE RUNS*
  Updates to ELK pipeline components and apt pinning of package major versions. Config
  support and new cron entry for `mh-user-action-harvester` `load_episodes` command.

  Manual recipe run should come after any MH release/deploy and an `update_chef_recipes`.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Analytics" recipes="oc-opsworks-recipes:install-elasticsearch,oc-opsworks-recipes::install-logstash-kibana,oc-opsworks-recipes::install-ua-harvester"

## 1.11.0 - 9/8/2016

* `moscaler_release` now defaults to "master"
* *REQUIRES MANUAL CHEF RECIPE RUN*
  Additional helpful utils to be installed by default

        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::install-utils"
* prevent autofs restart only if existing mount matches the storage hostname. this
  enables use of the `nfs-client` recipe for switching storage nodes or zadara vpsas
* *REQURES EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Capture agent time drift metrics generation via utility node. Update the cluster config
  to include the `ca_private_ssh_key` value in the `caputure_agent_manager` custom json
  block, add the `oc-opsworks-recipes::install-capture-agent-timedrift-metric` recipe
  to the utility node's setup phase, then manually run:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Utility" recipes="oc-opsworks-recipes::install-ca-timedrift-metric"

## 1.10.0 - 8/12/2016

* *REQURES EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Changes to moscaler configuration deployment. Updated config will be detailed in the MH release notes.
  After an `update_chef_recipes` do a manual recipe exec:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="oc-opsworks-recipes::install-moscaler"

* *REQURES EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Fixes to the recipe/script that provides the MatterhornJobsQueue metric. Cluster config
  should be updated to include the `install-job-queued-metrics` recipe. See MH release notes for more deets.
  After an `update_chef_recipes` do
  a manual recipe exec:

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="oc-opsworks-recipes::install-job-queued-metrics"

## 1.9.0 - 7/21/2016

* *REQUIRES EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Renames `install-ec2-scaling-manager` to `install-moscaler` and updates the
  recipe to allow control of the scaling strategy (time vs autoscale) as
  well as disabling entirely. See `README.horizontal_scaling.md` in the
  [mh-opsworks](https://github.com/harvard-dce/mh-opsworks) repo for details.

## 1.8.0 - 7/13/2016

* Fixed notification email
* Added live_monitor_url config for live akamai stream monitoring
"stack": {
    "chef": {
    "custom_json": {
        "live_monitor_url": rtmp:akamai_server:port/../#{caName}/...

## 1.7.0 - 7/5/2016

* Added stack short name to config.properties so that we can show the cluster name when sending notification emails.

## 1.6.0 - 6/24/2016

* Configuration for the newrelic is now different for each layer (admin,work,engage)
"stack": {
    "chef": {
    "custom_json": {
      "newrelic": {
        "admin": { "key": "admin_newrelic_key" },
        "workers": { "key": "worker_newrelic_key" }
      }
    ...
If the newrelic key or a layer name is omitted, new relic will not be run for the stack or the layer.
all-in-one deployment will use admin key.

## 1.5.0 - 6/10/2016

* Configuration for the new Matterhorn aws s3 file archive service (s3 bucket name).
* *[OPTIONAL]* Changes to the `install-ua-harvester` recipe. Changed naming path
  of the s3 bucket used to store the useraction harvester's last action timestamp
  value. Only relevant for analytics node and only affects new clusters. Also
  bumped harvest batch size from the default 1000/per

## 1.4.0 - 6/8/2016

* *[OPTIONAL]* Recipes to install and configure the utility node to host the
  capture-agent-manager flask-gunicorn webapp. The utility node is optional and
  only for DCE production cluster.

* *[OPTIONAL] EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  recipes, etc to install and configure the utility node to host the capture-agent
  manager flask-gunicorn webapp. See README.capture-agent-manager.md in
  mh-opsworks for setup instructions.

  The manual recipe run can be executed any time since they affect only the
  utility node

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Utility"
        recipes="oc-opsworks-recipes::create-capture-agent-manager-user,oc-opsworks-recipes::create-capture-agent-manager-directories,oc-opsworks-recipes:install-capture-agent-manager-packages,oc-opsworks-recipes:install-capture-agent-manager,oc-opsworks-recipes:configure-capture-agent-manager-gunicorn,oc-opsworks-recipes:configure-capture-agent-manager-nginx-proxy,oc-opsworks-recipes:configure-capture-agent-manager-supervisor"


## 1.3.3 - 5/19/2016

* Fix `oc-opsworks-recipes::install-ec2-scaling-manager` to correctly update
  the cron jobs when run. Implement basic serverspec tests to ensure the
  default attributes and a run with customized attributes works. Nothing to
  run.
* Fix all-in-one node provisioning, primarily for local vagrant development.
  Nothing to run.
* Only update apt repo if it's more than 30 minutes old. Nothing to be run.
* Recipe level docs. There are no functional changes in this feature. Nothing
  to run.
* Implement foodcritic linting via [travis](https://travis-ci.org). Nothing to
  run.
* Use the service resource to idiomatically start services. Nothing to run, just
  make sure that matterhorn starts correctly after a deploy.
* Fix and improve test-kitchen bats tests. Nothing to run.
* Better docs.

## 1.3.2 - 4/22/2016

* Local opsworks cluster support, in concert with changes made to mh-opsworks
  proper.  Modify some chef recipes to only run functions when on AWS. Nothing
  is required to be run outside of a normal deploy. See `README.local-opsworks.md`
  in mh-opsworks for full info on how this feature works.

## 1.3.1 - 4/14/2016

* Start matterhorn at boot via cron's @reboot functionality. Runs automatically
  as part of a deploy.
* *REQUIRES MANUAL CHEF RECIPE RUNS* * MUST BE RUN BEFORE THE DEPLOY*
  Change the `dont_start_matterhorn_after_deploy` stack `custom_json` override
  to `dont_start_matterhorn_automatically` because it has a larger scope now.
  When set to `true`, this allows you to start ec2 instances without starting the
  matterhorn daemon.  This hooks into the init script (no other way, really) and
  will prevent matterhorn from booting until you unset it or set it to `false`.
  That's a lot of scary words for something that'll only impact you if you
  explictly use it. If you want to start matterhorn after disabling it with the
  variable, you: 1) remove or edit the variable in your cluster config via
  "cluster:edit", and 2) run "matterhorn:restart" via the mh-opsworks tooling.
  Using the mh-opsworks tooling will propagate the `custom_json` change and
  ensure matterhorn can start properly.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::install-mh-base-packages"

## 1.3.0 - 4/7/2016

* *REQUIRES MANUAL CHEF RECIPES RUNS* *MUST BE RUN BEFORE THE DEPLOY*  Update the
  version of node on the cluster to work around an npm / gzipping bug.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::install-mh-base-packages"

* *REQUIRES MANUAL CHEF RECIPE RUNS* Hang more alarms on database metrics to catch
  problems relating to disk IO. Lower the CPU threshold.  This can be done any
  time before or after a deploy.

        # This is currently on the "Ganglia" layer in prod,
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="oc-opsworks-recipes::create-mysql-alarms"

* *REQUIRES MANUAL CHEF RECIPE RUNS* Add a metric and alarm to check if
  instances fail to start up. This can be done any time before or after a
  deploy.

        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::install-custom-metrics,oc-opsworks-recipes::create-alerts-from-opsworks-metrics"

* *OPTIONAL EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Recipes, etc for setting up Analytics layer/node. See README.analytics.md in
  mh-opsworks for setup instructions.
  The manual recipe run can be executed any time after a successful deploy.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Engage" recipes="oc-opsworks-recipes::configure-engage-nginx-proxy"

## 1.2.0 - 3/23/2016

* Allow for cluster state to be turned into a "seed file" and applied to
  another cluster.  See `README.cluster_seed_files.txt` in
  https://github.com/harvard-dce/mh-opsworks/ for more information on how this
  feature works. Does not require specific chef recipes be run for a
  deployment.
* Fix the squid3 proxy ACL to correct rules for s3 endpoints - the zadara docs
  were very, very wrong. This does not require an explicit chef recipe run.
* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Updated loggly TLS certificate. Manual recipe run can be executed any time
  after a successful deploy.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::rsyslog-to-loggly"

## 1.1.6 - 3/3/2016

* *REQUIRES EDITS TO THE CLUSTER CONFIG* *REQUIRES MANUAL CHEF RECIPE RUNS*:
  Before doing a deploy and after the morning scaled instances have started,
  you must edit the production cluster config `custom_json` to set:

        "matterhorn_repo_root": "/opt/matterhorn/deploy",
        "nginx_log_root_dir": "/opt/matterhorn",

  `matterhorn_repo_root` already exists and should be updated -
  `nginx_log_root_dir` is new and should be created. Proceed to update chef
  recipes and do your deploy normally after that.

  This new feature clarifies the name of the deployed app and allows it to
  easily be moved into a separate subdirectory under /opt/matterhorn.  The manual
  recipe run below can be run at any time after a successful deploy.

        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::remove-legacy-deploy-dir"

* *REQUIRES MANUAL CHEF RECIPE RUNS*: Open up nginx logs to be world-readable
  by default. This happens post daily log rotation

        # After the recipes have been updated. . .
        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::configure-nginx-proxy" layers="Admin, Workers"
        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::configure-engage-nginx-proxy" layers="Engage"

## 1.1.5 - 2/25/2016

* Create a squid3 proxy to be used by the zadara storage array to get to s3 for
  object store backups.  See
  [mh-opsworks](https://github.com/harvard-dce/mh-opsworks/blob/master/README.zadara.md)
  for more information about how to use this recipe. This recipe is independent
  of deployments.

* *REQUIRES MANUAL CHEF RECIPE RUNS:* Set the bash prompt to be in color and
  put the cluster name in there. When a cluster includes "production" in the
  name, make it red so that users know they're working in production.  This is
  not tied to deployment and can be run at any time

        ./bin/rake stack:commands:execute_recipes_on_instances recipes="oc-opsworks-recipes::set-bash-as-default-shell"

* *REQUIRES MANUAL CHEF RECIPE RUNS*: This recipe can be run at any time and
  is deploy independent.  Switch to daily mysql backups as a way of having a
  historical record of database state. RDS gives you the ability to restore to
  any point in time back to the beginning of your retention period (30 days for
  production), obviating the value and pretty major resource drain hourly MySQL
  dumps impose on production. Be sure to confirm which layer you're running
  your mysql backups on before running the command below:

        # This is currently on the "Ganglia" layer in prod,
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="oc-opsworks-recipes::install-mysql-backups"

* Ignore 401s in newrelic logging.

## 1.1.4 - 2/18/2016

* *REQUIRES MANUAL CHEF RECIPE RUNS*: Copy and symlink the nginx log dir to
  /opt/matterhorn/nginx. This should be registered into the engage layer's
  `setup` recipes and run whenever. It does not have to be run during a deploy.

        ./bin/rake stack:commands:execute_recipes_on_instances recipes="oc-opsworks-recipes::symlink-nginx-log-dir" hostnames="engage1"

  Remove the `/var/log/nginx_old` directory after you've manually confirmed logs
  are going to the right place.
* Allow java unit tests to be run during a (re)deploy. They do not run by
  default.  If you want to run them by default for all deploys set
  `skip_java_unit_tests` to `false` in your cluster config's `custom_json`
  config. You can run unit tests manually via the
  `deployment:redeploy_app_with_unit_tests` rake task.
* *REQUIRES MANUAL CHEF RECIPE RUNS*: Use maven3 instead of maven2, prepares us
  for matterhorn 1.6.x

    # Right before the deploy. . .
        ./bin/rake stack:commands:update_chef_recipes stack:commands:execute_recipes_on_layers layers="Admin, Workers, Engage" recipes="oc-opsworks-recipes::install-mh-base-packages"

* *REQUIRES MANUAL CHEF RECIPE RUNS* Install a cloudwatch metric and alarm to
  track nfs mount space available. Does not require anything to be done during
  a deployment.

        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::install-custom-metrics,oc-opsworks-recipes::create-alerts-from-opsworks-metrics"

* Install awscli directly, without the awscli recipe. Simplifies dependencies
  significantly. Does not require manual chef recipe runs, it'll run
  automatically when needed by other recipes.

## 1.1.3 - 2/17/2016

* HOTFIX - define dependencies better to ensure we stay with chef 11 compatible
  cookbooks. Fixes `awscli` cookbook which depends on the broken
  `build-essential` cookbook.

## 1.1.2 - 2/10/2016

* Allow the "create-file-uploader-user" recipe to fail, to work around
  mysterious "usermod: no options" chef bug. Does not require anything to be
  done during a deployment. The recipe always works the first time it's run, it's
  just the second time that we sometimes see this failure.

## 1.1.1 - 2/3/2016

* Allow java debug to be set to `true` or `false` via the `java_debug_enabled`
  stack `custom_json` parameter. It currently defaults to "true" (so, enabled)
  because most clusters are going to be development or testing clusters.
* Install the newrelic agent when '{"newrelic": {"key": "your key"}' is
  included in the stack's `custom_json`. See the main mh-opsworks README for
  info.
* *REQUIRES MANUAL CHEF RECIPE RUNS* Make the mysql dumps more bandwidth
  efficient by using "--compress" on the mysqldump client and an inline gzip
  when saving to shared storage. This causes bandwidth during mysql dumps to
  drop by 4 or 5 times without an appreciable performance penalty.  This recipe
  can by run at any time, be sure to confirm the instance your dumps are
  happening on by finding this recipe in your active cluster config.

        # This is currently on the "Ganglia" layer in prod,
        # the value below is for dev clusters.
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="oc-opsworks-recipes::install-mysql-backups"
* *REQUIRES OPTIONAL CHEF RECIPE RUNS*  Installs the `file_uploader` user onto
  the instance of your choice. This allows you to use an rsync backchannel for
  uploads directly to the matterhorn inbox in combination with a couple cron jobs
  to copy and maintain these uploads. If you want to use this feature, add it to
  the setup lifecycle in the appropriate layer in your cluster config and then
  run this recipe.  This recipe does not need to be run at any particular time
  relative to a deployment.

        # The current value for the admin node
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="oc-opsworks-recipes::create-file-uploader-user"

## 1.1.0 - 1/28/2016

* All clusters should now include a `private_assets_bucket_name` in their
  cluster config, which can be the same as the `cluster_config_bucket_name` as
  that's a private bucket too and includes some shared assets.
* *REQUIRES CHEF RECIPE RUNS* Rotate nginx logs more aggressively than a week,
  but still keep a year. All this change does is install a new logrotate file,
  overriding the default. The recipes can be run whenever.

        # After the recipes have been updated. . .
        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::configure-nginx-proxy" layers="Admin, Workers"
        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::configure-engage-nginx-proxy" layers="Engage"

* *REQUIRES MANUAL CHEF RECIPE RUNS* Remove the "ok-action" alarms - they are
  too chatty and not useful. These recipe runs can happen post-deploy.

        ./bin/rake stack:commands:execute_recipes_on_layers recipes="oc-opsworks-recipes::create-alerts-from-opsworks-metrics"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Ganglia" recipes="oc-opsworks-recipes::create-mysql-alarms"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin" recipes="oc-opsworks-recipes::install-mysql-backups"
        ./bin/rake stack:commands:execute_recipes_on_layers layers="Admin,Workers,Engage,Utility,Asset Server" recipes="oc-opsworks-recipes::nfs-client"

  Be sure to double-check all layers and recipe combinations.

## 1.0.7 - 1/21/2016

* Clean up s3 distribution configuration. Remove asset server hooks.
* *REQUIRES MANUAL CHEF RECIPE RUNS* engage nginx uid cookie & usertracking
  session id + uid log for identifying shopping period viewers
* *REQUIRES MANUAL CHEF RECIPE RUNS* Use mo-scaler --scale-available option

## 1.0.6 - 1/18/2016

* Configuration for the new Matterhorn S3 distribution service.

## 1.0.5 - 1/14/2016

* Hot fix for Otherpubs sevice config

## 1.0.4 - 1/14/2016

* *REQUIRES MANUAL CHEF RECIPE RUNS* Send X-Forwarded-For header from the nginx
  proxies so that user-tracking gets correct client ip
* Get rid of the no longer necessary ffmpeg package removal
* Modify `mh_default` and otherpubs config for MATT-1822 auto populate admin UI upload

## 1.0.3 - 1/8/2016

* Fix find's mtime invocation to ensure we're compressing and reaping files at
  the correct times. *Requires that the MySQL backup installation chef recipe be
  run on the admin node.*
* Relax the `matterhorn_availability` alert to require errors over two 2 minute
  periods instead of just one.
* Modify the matterhorn init script to check that the daemon started properly,
  working around the race condition related to bundle loading. See the relevant
  commit for details.

## 1.0.2 - 1/6/2016

* Only set the `org.opencastproject.server.maxload` property on worker nodes -
  all other nodes can have an unlimited number of jobs.

## 1.0.1 - 1/5/2016

* Allow the default "start matterhorn if it's not running after deploy" to be
  overridden via the `:dont_start_matterhorn_after_deploy` chef `custom_json`
  attribute.

## 1.0.0 - 1/4/2016

* Initial release
