name             'oc-opsworks-recipes'
maintainer       'Jay Luker'
maintainer_email 'jay_luker@harvard.edu'
license          'All rights reserved'
description      'Installs/Configures oc-opsworks-recipes'
long_description 'Installs/Configures oc-opsworks-recipes'
version          '0.1.0'
issues_url       'http://github.com/harvard-dce/oc-opsworks-recipes/issues' if respond_to?(:issues_url)
source_url       'http://github.com/harvard-dce/oc-opsworks-recipes/' if respond_to?(:source_url)

recipe(
  'oc-opsworks-recipes::default',
  'This cookbook does nothing by default'
)
recipe(
  'oc-opsworks-recipes::nfs-client',
  'Sets up an instance to connect to an NFS export.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_info

=== Effects
* nfs-client packages installed
* autofs tooling to mount the NFS drive.
* autofs is restarted if we do not have an active mount
* install a cloudwatch alarm and metric if we are on aws
'
)
recipe(
  'oc-opsworks-recipes::nfs-export',
  'Sets up an instance to export a directory via nfs

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_info and get_shared_storage_root

=== Effects
* install nfs server packages
* configure /etc/exports with the directory and cidr block from the config
* ensure the export is owned by the opencast user
'
)
recipe(
  'oc-opsworks-recipes::deploy-admin',
  'Sets up an instance to be an admin node

See the chef "deploy_revision" resource to understand how our deploys work.

=== Attributes
* Many. See MhOpsworksRecipes::RecipeHelpers and MhOpsworksRecipes::DeployHelpers

=== Effects
* does a maven build with the admin profile
* configures after a successful build
* restarts opencast if it is not running already
* runs oc-opsworks-recipes::monitor-opencast-daemon to install cloudwatch
  metrics and alarms
* registers the opencast service to start on instance boot
'
)
recipe(
  'oc-opsworks-recipes::set-timezone',
  'Sets the timezone on a node

=== Attributes
* <tt>node[:timezone]</tt>

=== Effects
* Sets the timezone to "America/New_York" or whatever you set in <tt>node[:timezone]</tt>
'
)
recipe(
  'oc-opsworks-recipes::install-utils',
  'Installs utility packages useful on all nodes for debugging

=== Attributes
* none

=== Effects
* the package repo lists are updated
* utility packages are installed
* the package cache is cleared to save space
'
)
recipe(
  'oc-opsworks-recipes::remove-alarms',
  'Removes cloudwatch alarms associated with an instance

This should be run during the opsworks "shutdown" lifecycle events

=== Attributes
* none

=== Effects
* the python aws cli is used to get a list of alarms associated with the instance
* that list of alarms is removed via the python aws cli
'
)
recipe(
  'oc-opsworks-recipes::deploy-worker',
  'Sets up an instance to be a worker node

See the deploy-admin docs for more info.'
)
recipe(
  'oc-opsworks-recipes::deploy-engage',
  'Sets up an instance to be the engage node

See the deploy-admin docs for more info.'
)
recipe(
  'oc-opsworks-recipes::install-kibana',
  'Sets up a node to work as a Kibana analytics instance

You should add a layer as defined in
{mh-opsworks/README.analytics.md}[https://github.com/harvard-dce/mh-opsworks/blob/master/README.analytics.md].
That layer will use this recipe to install kibana.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_elk_info primarily

=== Effects
* A kibana user is and group is created
* kibana is installed
'
)
recipe(
  'oc-opsworks-recipes::install-ffmpeg',
  'Install our custom build of ffmpeg to the node

This installs our custom ffmpeg build created by
{ffmpeg-build}[https://github.com/harvard-dce/ffmpeg-build].

You must build a new version of ffmpeg and upload it to aws according to the
docs in the ffmpeg-build project above.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_shared_asset_bucket_name
* <tt>node[:ffmpeg_version]</tt>

=== Effects
* ffmpeg, ffprobe, ffplay, ffserver, and x264 are installed and symlinked to
  /usr/local/bin
'
)
recipe(
  'oc-opsworks-recipes::install-run-one',
  'Install the run-one script for cron jobs

This installs the packaged run-one script that isn\'t available
for non-ubuntu distros so we cribbed it from ubuntu

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_shared_asset_bucket_name

=== Effects
* run-one script is installed and symlinked to /usr/bin
'
)
recipe(
  'oc-opsworks-recipes::install-awscli',
  'Installs the commandline aws-cli client

The default version is <tt>1.27.78</tt>. You can install whatever version you
want by setting the parameter below.

=== Attributes
* <tt>node[:awscli_version]</tt>

=== Effects
* the awscli python package is installed
'
)
recipe(
  'oc-opsworks-recipes::load-seed-data',
  'loads seed database and files as part of the cluster seed functionality

This downloads a cluster seed from aws, extracts the files and loads and
applies local modifications to the database. It is run by the
<tt>cluster:apply_seed_file</tt> rake task in oc-opsworks.

This should only be run on development clusters, as defined by
MhOpsworksRecipes::RecipeHelpers.dev_or_testing_cluster?

=== Attributes
* Many, mostly related to hostnames and file paths.

=== Effects
* files in the current cluster are replaced with the files from the seed
* the database in the current cluster is replaced with the database from the
  seed
* the newly applied database is modified to reflect the current cluster
  environment
'
)
recipe(
  'oc-opsworks-recipes::install-nodejs',
  'installs static binaries of nodejs and npm

This installs the official static binaries of nodejs and npm to
<tt>/usr/local/bin/</tt>

=== Attributes
* <tt>node[:node_version]</tt>, defaults to <tt>0.12.1</tt>

=== Effects
* the ubuntu node packages are removed
* the official node static binaries are installed.
'
)
recipe(
  'oc-opsworks-recipes::reset-database',
  'resets the opencast database a clean post-first-deploy state

This should only be run on development clusters, as defined by
MhOpsworksRecipes::RecipeHelpers.dev_or_testing_cluster?.

This is part of the cluster seed infrastructure implemented in oc-opsworks.

=== Attributes
* <tt>node[:db_seed_file]</tt>, defaults to <tt>dce-config/docs/scripts/ddl/mysql5.sql</tt>

=== Effects
* The database is deleted
* The default database seed is applied as defined by <tt>node[:db_seed_file]</tt>
'
)
recipe(
  'oc-opsworks-recipes::deploy-database',
  'deploys the default database seed to this node

Only used in local opsworks clusters where we are not using RDS.

=== Attributes
* Many, but <tt>node[:db_seed_file]</tt> is probably most important as it controls what seed file is loaded

=== Effects
* The db seed file is loaded into the database
'
)
recipe(
  'oc-opsworks-recipes::stop-opencast',
  'stops opencast via the opencast service config

=== Attributes
* none

=== Effects
* opencast is stopped
'

)
recipe(
  'oc-opsworks-recipes::start-opencast',
  'start opencast via the opencast service config

=== Attributes
* <tt>node[:dont_start_opencast_automatically]</tt> if set to true will abort starting opencast

=== Effects
* opencast is started
'
)
recipe(
  'oc-opsworks-recipes::install-logstash',
  'Sets up logstash on a node

See also <tt>oc-opsworks-recipes::install-kibana</tt>. This installs the
logstash part of our analytics layer.

=== Attributes
* <tt>node[:logstash_major_version]</tt> the major version of logstash to configure the apt repo
* <tt>node[:logstash_version]</tt> the version of logstash to install

=== Effects
* logstash is installed
* logstash is configured
'
)
recipe(
  'oc-opsworks-recipes::deploy-all-in-one',
  'FIXME: deploys an all-in-one node.'
)
recipe(
  'oc-opsworks-recipes::rsyslog-to-loggly',
  'installs and configures rsyslog to send logs to loggly.com

=== Attributes
* <tt>node[:loggly]</tt> - include the "token" and "url" keys. If absent nothing will be configured.

=== Effects
* the rsyslog-gnutls package is installed
* if the loggly token and URL are present, configure rsyslog to send tagged
  logs to loggly
  '
)
recipe(
  'oc-opsworks-recipes::install-deploy-key',
  'Installs a private deploy ssh key for the opencast user

=== Attributes
* <tt>node[:deploy][:opencast][:scm]</tt>, which comes from the opsworks app configuration

=== Effects
* the private key is put into <tt>/home/opencast/.ssh/</tt>
* a basic ssh config is installed to <tt>/home/opencast/.ssh/config</tt>
'
)
recipe(
  'oc-opsworks-recipes::restart-opencast',
  'restarts the opencast service

=== Attributes
* <tt>node[:dont_start_opencast_automatically]</tt> if set to true will abort starting opencast

=== Effects
* opencast will be restarted
'
)
recipe(
  'oc-opsworks-recipes::maintenance-mode-on',
  'Sets opencast maintenance mode on for this node

=== Attributes
* none

=== Effects
* We send an API request to the admin node to put this node into maintenance
  mode
'
)
recipe(
  'oc-opsworks-recipes::update-package-repo',
  'Updates the package repo to ensure we have the latest package lists

=== Attributes
* none

=== Effects
* half-configured packages are fixed
* the package list is updated
'
)
recipe(
  'oc-opsworks-recipes::create-mysql-alarms',
  'create cloudwatch metrics and alarms against the RDS instance

=== Attributes
* MhOpsworksRecipes::RecipeHelpers

=== Effects
* Numerous cloudwatch alarms are created for space, CPU, storage, RAM, and IO
* These alarms are bound directly to the RDS instance
'
)
recipe(
  'oc-opsworks-recipes::populate-maven-cache',
  'Download and extract a maven cache seed

This grabs and extracts a tarball containing a maven cache from the shared
asset bucket. This speeds up builds greatly on new nodes.  You can update the
seed via the <tt>admin:republish_maven_cache</tt> rake task in oc-opsworks.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_shared_asset_bucket_name

=== Effects
* The maven cache is downloaded and extracted to <tt>/root/.m2/</tt>
'
)
recipe(
  'oc-opsworks-recipes::maintenance-mode-off',
  'Sets opencast maintenance mode off for this node

=== Attributes
* none

=== Effects
* We send an API request to the admin node to turn off maintenance mode for
  this node
'
)
recipe(
    'oc-opsworks-recipes::install-ua-harvester',
    'installs the user analytics harvester as part of the ELK analytics

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_elk_info
* MhOpsworksRecipes::RecipeHelpers.get_rest_auth_info

=== Effects
* Install python, redis and run-one packages
* Create a ua_harvester user
* git checkout and install {mh-user-action-harvester}[https://github.com/harvard-dce/mh-user-action-harvester.git]
* set up a cron job to harvest actions every 2 minutes
* create an sqs queue for analytics processing
'
)
recipe(
  'oc-opsworks-recipes::configure-ua-harvester',
  'generates the .env configuration file for the useraction harvester

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_elk_info

=== Effects
* generates the .env config file
'
)
recipe(
  'oc-opsworks-recipes::remove-admin-indexes',
  'Remove solr indexes on the admin node

Remove the solr indexes from the admin node as part of resetting a cluster to a
pristine state.

This is part of the cluster seed infrastructure implemented in oc-opsworks.

=== Attributes
* none. Can only be run on a dev or testing cluster as defined by MhOpsworksRecipes::RecipeHelpers.dev_or_testing_cluster?

=== Effects
* Removes the solr index files on the admin node
'
)
recipe(
  'oc-opsworks-recipes::remove-engage-indexes',
  'Remove solr indexes on the engage node.

See <tt>oc-opsworks-recipes::remove-admin-indexes</tt>.
'
)
recipe(
  'oc-opsworks-recipes::install-mysql-backups',
  'Install mysql backups and metrics / alarms related to backup freshness

This runs as root and authenticates to mysql via the /root/.my.cnf written by
<tt>oc-opsworks-recipes::write-root-my-dot-cnf</tt>.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_info

=== Effects
* A daily full mysql dump is put on the shared storage directory
* A metric and alarm is added to ensure the daily backups are happening.
* Cron jobs are installed to ensure the backups and metrics happen
'
)
recipe(
  'oc-opsworks-recipes::install-elasticsearch',
  'install elasticsearch as part of the ELK user analytics stack

See oc-opsworks-recipes::install-kibana and the other ELK-related recipes for
more info.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_elk_info primarily

=== Effects
* configure the custom elasticsearch (and other related) repos
* install and configure elasticsearch and the python-elasticsearch-curator
* enable the elasticsearch service at boot
* install and configure kopf
* install our custom useractions template
* optionally enable dumping snapshots to an s3 bucket
'
)
recipe(
  'oc-opsworks-recipes::write-root-my-dot-cnf',
  'write a /root/.my.cnf on the node that connects to the database

=== Attributes
* <tt>node[:deploy][:opencast][:database]</tt>, the default opsworks database attributes

=== Effects
* Installs a <tt>/root/.my.cnf</tt> file that connects the root user on this
  node to the default opencast MySQL instance.
'
)
recipe(
  'oc-opsworks-recipes::symlink-nginx-log-dir',
  'Copies contents and symlinks /var/log/nginx to an alternate directory

=== Attributes
* <tt>node[:nginx_log_root_dir]</tt> The root directory for the new location.
  We create the <tt>nginx</tt> dir for you.
* <tt>node[:old_nginx_log_root_dir]</tt> The old root directory for the nginx logs. Defaults to <tt>/var/log/</tt>.

=== Effects
* Does not do anything if <tt>node[:old_nginx_log_root_dir]/nginx</tt> is already a symlink
* Copy the files from old_nginx_log_root_dir to nginx_log_root_dir
* Rename the old directory to <tt>node[:old_nginx_log_root_dir]/nginx_old</tt>
* Set up the symlink
* Reload nginx to bind logs correctly to the new dir
'
)
recipe(
  'oc-opsworks-recipes::configure-nginx-proxy',
  'A basic nginx proxy configuration

=== Attributes
* none

=== Effects
* Installs nginx
* Proxies *:80 back to localhost:8080
* Configures improved log rotation
* Sets up a <tt>/etc/nginx/proxy-includes</tt> directory to hold additional customizations
* Reloads nginx afterwards
'
)
recipe(
  'oc-opsworks-recipes::create-opencast-user',
  'Creates the opencast user

=== Attributes
* none

=== Effects
* Creates a opencast group and user
* Creates the <tt>/home/opencast/.ssh</tt> directory
'
)
recipe(
  'oc-opsworks-recipes::install-custom-metrics',
  'Installs metrics for disk, RAID sync, mysql availability, load, memory and others

=== Attributes
* None

=== Effects
* Installs scripts and cron jobs that submit metrics to cloudwatch
* Installs a mysql availability metric on the admin node (which should have a
  working <tt>/root/.my.cnf</tt> by default)
'
)
recipe(
  'oc-opsworks-recipes::clean-up-package-cache',
  'Cleans up the cached dpkgs to save disk space

=== Attributes
* none

=== Effects
* Cleans up the package cache
'
)
recipe(
  'oc-opsworks-recipes::install-logstash-kibana',
  'Installs kibana and logstash

This runs <tt>oc-opsworks-recipes::install-kibana</tt> and
<tt>oc-opsworks-recipes::install-logstash</tt>
'
)
recipe(
  'oc-opsworks-recipes::remove-legacy-deploy-dir',
  'Allows you to remove a legacy deploy dir when changing where opencast is deployed

=== Attributes
* <tt>node[:legacy_deploy_root]</tt>

=== Effects
* Removes the /releases, /shared, and /current dirs and symlinks under
  <tt>node[:legacy_deploy_root]</tt>
'
)
recipe(
  'oc-opsworks-recipes::install-oc-base-packages',
  'Install base packages for opencast nodes

=== Attributes
* none

=== Effects
* Installs openjdk, python, etc.
* Installs nodejs via <tt>oc-opsworks-recipes::install-nodejs</tt>
'
)
recipe(
  'oc-opsworks-recipes::create-cluster-seed-file',
  'Creates a cluster seed from the current cluster to be applied to a different cluster

=== Attributes
* Many, mostly about the current cluster.

This should only be run on development clusters, as defined by
MhOpsworksRecipes::RecipeHelpers.dev_or_testing_cluster?

=== Effects
* A seed file including the files, database, and a manifest of the current cluster config is created
* This is uploaded to an s3 bucket as defined by <tt>node[:cluster_seed_bucket_name]</tt>
'
)
recipe(
  'oc-opsworks-recipes::enable-postfix-smarthost',
  'Enables a postfix smarthost through a configured SES endpoint

This allows you to send email directly over the SMTP server on localhost via
the postfix smarthost.

=== Attributes
* <tt>node[:smtp_auth]</tt>

=== Effects
* postfix is installed
* postfix is configured to relay over the SES endpoint (or other SMTP server)
  as defined in <tt>node[:smtp_auth]</tt>
* postfix is reload afterwards.
'
)
recipe(
  'oc-opsworks-recipes::create-file-uploader-user',
  'Creates a system to allow for the direct upload of files into the opencast inbox

=== Attributes
* <tt>node[:file_uploader_public_ssh_key]</tt>
* MhOpsworksRecipes::RecipeHelpers.get_storage_info
* MhOpsworksRecipes::RecipeHelpers.get_shared_storage_root

=== Effects
* Installs rsync
* Creates the <tt>rsync_uploads</tt> dir on the nfs export
* Creates a <tt>file_uploader</tt> user
* Installs a "forced command" ssh key that allows the <tt>file_uploader</tt>
  use to upload via rsync to the <tt>rsync_uploads</tt> dir
* Install a cron job to move uploads into the opencast inbox
* Install a cron job to remove stale unfinished uploads
'
)
recipe(
  'oc-opsworks-recipes::monitor-opencast-daemon',
  'Add metrics and alarms to monitor the status of the opencast daemon

Installs metrics, alarms, and cron jobs that monitoring the opencast daemon
if we are on aws

=== Attributes
* none

=== Effects
* Install a metric script
* Install a cron job to run it
* Create a cloudwatch alarm hitched up to the opencast availability metric
'
)
recipe(
  'oc-opsworks-recipes::configure-elk-nginx-proxy',
  'Sets up an nginx proxy that allows connections to elasticsearch on the local network

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_elk_info primarily

=== Effects
* A configured and restarted nginx linked to elasticsearch
* HTTP basic auth protection for the kibana interface
'
)
recipe(
  'oc-opsworks-recipes::install-job-queued-metrics',
  'This is stub that includes the install-job-load-metrics recipe. It was left in for backwards compatibility.
'
)
recipe(
    'oc-opsworks-recipes::install-job-load-metrics',
    'Installs shell and python scripts for generating several metrics useful for horizontal scaling.
'
)
recipe(
  'oc-opsworks-recipes::remove-all-opencast-files',
  'Removes all opencast files on shared storage and distributed to s3

This removes all files from the clusters shared nfs mount and distributed to
s3.  You probably should not use this directly.

This is part of the cluster seed infrastructure implemented in oc-opsworks.

This should only be run on development clusters, as defined by
MhOpsworksRecipes::RecipeHelpers.dev_or_testing_cluster?

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_info and get_shared_storage_root

=== Effects
* File are removed locally and on s3
'
)
recipe(
  'oc-opsworks-recipes::install-moscaler',
  'Installs the mo-scaler horizontal scaling manager

Depending on `custom_json` settings, will configure mo-scaler using either a time-based
scaling strategy or one of the auto-scaling methods.

=== Attributes
* <tt>node[:moscaler]</tt> - defines several options. See the recipe for more details.

=== Effects
* Creates the moscaler user
* Installs mo-scaler
* Generates a `.env` file in /home/moscaler/mo-scaler based on attributes defined in <tt>node[:moscaler]</tt>
* Sets up cron jobs to scale according to the attributes defined in <tt>node[:moscaler]</tt>
'
)
recipe(
  'oc-opsworks-recipes::create-metrics-dependencies',
  'Installs shared code used by all cloudwatch metrics scripts

=== Attributes
* none

=== Effects
* Installs the shared cloudwatch metrics script used to define the region and
  base namespace
'
)
recipe(
  'oc-opsworks-recipes::configure-opencast-service',
  'FIXME'
)
recipe(
  'oc-opsworks-recipes::configure-engage-nginx-proxy',
  'Configure the nginx proxy on the engage node

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_info and get_shared_storage_root

=== Effects
* Configures an nginx proxy, including access to the transcoded files on the filesystem
* Reloads nginx after configuration
'
)
recipe(
  'oc-opsworks-recipes::create-opencast-directories',
  'Creates the base directories for opencast

This ensure the base directories on this node are created with the correct
permissions both for our local workspace and on the nfs shared directory

=== Attributes
* <tt>MhOpsworksRecipes::RecipeHelpers.get_local_workspace_root</tt> and others related to file paths

=== Effects
* Creates the directories and ensures they are owned by the opencast user.
'
)
recipe(
  'oc-opsworks-recipes::update-nginx-config-for-ganglia',
  'Updates the nginx proxy (probably on the admin node) to link <tt>/ganglia</tt> to the ganglia node

This runs during the "configure" lifecycle event.

=== Attributes
* none

=== Effects
* Installs the ganglia proxy config when the ganglia node is present
* Reloads the nginx service
'
)
recipe(
  'oc-opsworks-recipes::update-host-based-configurations',
  'Updates opencast nodes with the public admin and engage hostnames

This is probably no longer necessary. It updates the public engage and admin
hostnames during the configuration lifecycle event, the idea being that we
would spin up all nodes simultaneously and then start opencast at the end.

=== Attributes
* MhOpsworksRecipes::DeployHelpers.install_multitenancy_config
* MhOpsworksRecipes::RecipeHelpers.get_public_engage_hostname
* MhOpsworksRecipes::RecipeHelpers.get_public_admin_hostname

=== Effects
* updates etc/config.properties with hostnames
'
)
recipe(
  'oc-opsworks-recipes::create-alerts-from-opsworks-metrics',
  'Creates alerts for nodes from custom and built-in cloudwatch metrics

This is run during the setup phase of the opsworks lifecycle and adds
cloudwatch alarms for an instance. Some alarms have limits calculated on the
instance size (load) while others are simply percentages (disk, nfs).

=== Attributes
* Many, mostly from MhOpsworksRecipes::RecipeHelpers

=== Effects
* cloudwatch alarms are created
* They are removed when the instance shuts down.
'
)
recipe(
  'oc-opsworks-recipes::convert-mysql-to-multiple-data-files',
  'Converts MySQL innodb to use a file per table rather than one big one

This is not relevant for RDS database and is only useful for a self-hosted
MySQL database. It should be run during the setup lifecycle event.

=== Attributes
* <tt>node[:deploy][:opencast][:database]</tt>, the default opsworks database attributes

=== Effects
* MySQL is converted to use a single file per innodb table
* This only happens if the database install is brand new and the main
  opencast database has not been created.
'
)
recipe(
  'oc-opsworks-recipes::create-squid-proxy-for-storage-cluster',
  'Create a squid proxy to use for zadara s3 backups

This is used as a bridge between our zadara controller and the s3 bucket used
for s3-backed snapshot storage.

{More information
here}[https://support.zadarastorage.com/entries/69891364-Setup-Backup-To-S3-B2S3-Through-a-Proxy-In-Your-AWS-VPC]
and README.zadara.md in oc-opsworks.

=== Attributes
* MhOpsworksRecipes::RecipeHelpers.get_storage_hostname

=== Effects
* squid proxy service is installed
* squid is configured to allow proxy requests from the zadara controller
* squid is restarted to apply the new proxy config.
'
)
recipe(
    'oc-opsworks-recipes::install-crowdstrike',
    'Installs the CrowdStrike Falcon Sensor software. Because security.

**NOTE**: this software updates itself! The version running may be newer than the actual install package. The
yum package manager still keeps track of which package version was installed, so hopefully this will prevent a
situation where the recipe continually re-installs.

=== attributes
none

=== effects
* installs a stand-alone .rpm file from our oc-opsworks-shared-assets bucket
* installs to /opt/CrowdStrike
'
)
recipe(
    'oc-opsworks-recipes::exec-dist-upgrade',
    'Executes a yum update, necessary for installing kernel updates.

Note that this is above and beyond whatever it is Opsworks does when a layer/instance has
InstallUpdatesOnBoot set to true (the default). That operation will apply security and bugfix
package updates, but will not touch kernel updates.

=== attributes
none

=== effects
* performs a full yum update
* instances require restart before any kernel updates will take effect
'
)
recipe(
    'oc-opsworks-recipes::moscaler-resume',
    'Installs the moscaler cron entries

=== attributes
none

=== effects
* Installs the moscaler cron entries
'
)
recipe(
    'oc-opsworks-recipes::moscaler-pause',
    'Removes the moscaler cron entries, effectively disabling moscaler

=== attributes
none

=== effects
* removes the moscaler cron entries
'
)
recipe(
    'oc-opsworks-recipes::install-geolite2-db',
    'Installs the MaxmindDB GeoLite2 db for performing geoip lookups by the analytics harvester.

=== attributes
none

=== effects
* downloads the GeoLite2 db archive from the shared assets folder
* unpacks archive into /opt/geolite2
* name of archive file can be specified in cluster custom json
'
)
recipe(
    'oc-opsworks-recipes::configure-selinux',
    'Sets selinux to PERMISSIVE mode (log but don\'t block)

== attributes
none

== effects
* /etc/seclinux/config gets SELINUXMODE=Permissive
'
)
recipe(
  'oc-opsworks-recipes::create-karaf-var-directories',
  'Creates /var/run/opencast and /var/lock/opencast for karaf lock and pid files

== attributes
none

== effects
* /var/lock/opencast and /var/run/opencast are created and chowned to the opencast user
'
)
depends 'nfs', '~> 2.1.0'
# this addresses a dependency issue where we need to pin the version of line,
# which is a subdependency of another library, for compatibility reasons
depends 'line', '~> 0.6.3'
depends 'apt', '~> 2.9.2'
depends 'cron', '~> 1.6.1'
depends 'nodejs', '~> 2.4.4'
depends 'java', '1.47'
depends 'maven', '~> 2.2.0'
