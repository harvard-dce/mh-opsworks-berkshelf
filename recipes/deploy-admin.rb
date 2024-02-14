# Cookbook Name:: oc-opsworks-recipes
# Recipe:: deploy-admin

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
Chef::Provider::Deploy::Revision.send(:include, MhOpsworksRecipes::DeployHelpers)

opencast_repo_root = node[:opencast_repo_root]
local_workspace_root = get_local_workspace_root
storage_info = get_storage_info
shared_storage_root = get_shared_storage_root
rest_auth_info = get_rest_auth_info
admin_user_info = get_admin_user_info
stack_name = stack_shortname

using_local_distribution = is_using_local_distribution?

# S3 file archive service
region = node.fetch(:region, 'us-east-1')
s3_file_archive_bucket_name = get_s3_file_archive_bucket_name
s3_file_archive_enabled = !s3_file_archive_bucket_name.to_s.empty?
s3_file_archive_course_list = get_s3_file_archive_course_list
# S3 file archive service

# S3 cold archive service
s3_cold_archive_bucket_name = get_s3_cold_archive_bucket_name

# S3 distribution config to be used by the video export feature
enable_s3 = !using_local_distribution
region = node.fetch(:region, 'us-east-1')
s3_distribution_bucket_name = get_s3_distribution_bucket_name

# credentials for generating the signed urls for exporting videos
video_export_creds = get_video_export_credentials
video_export_access_key_id = video_export_creds[:access_key_id]
video_export_secret_access_key = video_export_creds[:secret_access_key]

# IBM Watson service credentials
ibm_watson_credentials = get_ibm_watson_credentials
ibm_watson_url = ibm_watson_credentials[:url]
ibm_watson_api_key = ibm_watson_credentials[:api_key]
ibm_watson_username = ibm_watson_credentials[:user]
ibm_watson_psw = ibm_watson_credentials[:pass]
ibm_watson_transcript_bucket = get_ibm_watson_transcript_bucket_name

# External elasticsearch index (admin ui + external api)
elasticsearch_host = get_elasticsearch_config[:host]
elasticsearch_protocol = get_elasticsearch_config[:protocol]
elasticsearch_port = get_elasticsearch_config[:port]

# Push series metadata to porta system
porta_conf = get_porta_metadata_conf
porta_enabled = porta_conf[:enabled]
porta_url = porta_conf[:porta_url]

# OPC-496 Zoom ingester config
zoom_ingester_config = get_zoom_ingester_config
zoom_ingester_url = zoom_ingester_config[:url]
zoom_ingester_api_key = zoom_ingester_config[:api_key]

capture_agent_monitor_url = node.fetch(
  :capture_agent_monitor_url, 'http://example.com/monitor_url'
)

live_monitor_url = node.fetch(
  :live_monitor_url, 'rtmp://example.com/live/#{caName}-presenter.delivery.stream-960x270_1_200@xyz'
)

immersive_classroom_url = node.fetch(
  :immersive_classroom_url, ''
)

immersive_classroom_engage_id = get_immersive_classroom_engage_id

live_streaming_url = get_live_streaming_url
live_stream_name = get_live_stream_name
distribution = using_local_distribution ? 'download' : 'aws.s3'

auth_host = node.fetch(:auth_host, 'example.com')

# OPC-149 other oc host for pub list merge
# The ignore_flag default value signals the config consumer
# That the value for the config was not intentionally set and should
# be ignored.
ignore_flag = 'IGNORE_ME'
other_oc_host = node.fetch(:other_oc_host, ignore_flag)
other_oc_prefother_series = node.fetch(:other_oc_prefother_series, ignore_flag)
other_oc_preflocal_series = node.fetch(:other_oc_preflocal_series, ignore_flag)

git_data = node[:deploy][:opencast][:scm]
git_revision = git_data.fetch(:revision, 'master')
oc_prebuilt_artifacts = node.fetch(:oc_prebuilt_artifacts, {})
use_prebuilt_oc = is_truthy(oc_prebuilt_artifacts[:enable])

public_engage_hostname = get_public_engage_hostname
public_engage_protocol = get_public_engage_protocol
public_admin_hostname = get_public_admin_hostname_on_admin
public_admin_protocol = get_public_admin_protocol
private_hostname = node[:opsworks][:instance][:private_dns_name]
nodename = node[:opsworks][:instance][:hostname]
cas_enabled = node.fetch(:cas_enabled, false)
cas_service = (public_admin_protocol + "://" + public_admin_hostname + "/cas") if cas_enabled

database_connection = get_database_connection

repo_url = git_repo_url(git_data)

include_recipe "oc-opsworks-recipes::create-opencast-directories"

allow_opencast_user_to_restart_daemon_via_sudo

deploy_action = get_deploy_action

deploy_revision "opencast" do
  deploy_to opencast_repo_root
  repo repo_url
  revision git_revision

  user 'opencast'
  group 'opencast'

  migrate false
  symlinks({})
  create_dirs_before_symlink([])
  purge_before_symlink([])
  symlink_before_migrate({})
  keep_releases 5
  action deploy_action

  before_symlink do
    most_recent_deploy = path_to_most_recent_deploy(new_resource)

    if use_prebuilt_oc
      install_prebuilt_oc(oc_prebuilt_artifacts[:bucket], git_revision, :admin, most_recent_deploy)
    else
      maven_build_for(:admin, most_recent_deploy)
    end

    # Copy in the configs as distributed in the git repo.
    # Some services will be further tweaked by templates
    copy_files_into_place_for(:admin, most_recent_deploy)

    copy_workflows_into_place_for_admin(most_recent_deploy)

    install_init_scripts(most_recent_deploy, opencast_repo_root)
    install_opencast_log_configuration(most_recent_deploy)
    install_opencast_log_management
    install_multitenancy_config(most_recent_deploy, public_admin_hostname, public_admin_protocol, public_engage_hostname, public_engage_protocol, stack_name, immersive_classroom_url, immersive_classroom_engage_id)

    install_elasticsearch_index_config(most_recent_deploy, stack_name)
    install_smtp_config(most_recent_deploy)
    install_default_tenant_config(most_recent_deploy, cas_enabled, public_admin_hostname)
    install_live_streaming_service_config(most_recent_deploy, live_stream_name, live_streaming_url, distribution)
    # Admin Specific
    install_otherpubs_service_config(most_recent_deploy, opencast_repo_root, auth_host, other_oc_host, other_oc_prefother_series, other_oc_preflocal_series, '')
    install_otherpubs_service_series_impl_config(most_recent_deploy)
    install_aws_s3_export_video_service_config(most_recent_deploy, enable_s3, region, s3_distribution_bucket_name, video_export_access_key_id, video_export_secret_access_key)
    install_aws_s3_file_archive_service_config(most_recent_deploy, region, s3_file_archive_bucket_name, s3_file_archive_enabled, s3_file_archive_course_list)
    install_aws_s3_cold_archive_service_config(most_recent_deploy, region, s3_file_archive_bucket_name, s3_cold_archive_bucket_name)
    # OPC-224 (only used during migration)
    install_ibm_watson_transcription_service_config(most_recent_deploy, ibm_watson_url, ibm_watson_api_key, ibm_watson_username, ibm_watson_psw)
    # OPC-554 porta metadata service
    install_porta_metadata_service(most_recent_deploy, porta_url, porta_enabled)
    # OPC-496
    install_adminui_tools_config(most_recent_deploy, zoom_ingester_url, zoom_ingester_api_key)
    unless ibm_watson_transcript_bucket.nil? or ibm_watson_transcript_bucket.empty?
      setup_transcript_result_sync_to_s3(shared_storage_root, ibm_watson_transcript_bucket)
    end
    install_published_event_details_email(most_recent_deploy, public_engage_hostname, public_engage_protocol)

    if using_local_distribution
      update_workflows_for_local_distribution(most_recent_deploy)
    end

    # ADMIN SPECIFIC
    # oc 11.x: Do not create the db tables
    # initialize_database(most_recent_deploy)
    # /ADMIN SPECIFIC

    template %Q|#{most_recent_deploy}/etc/custom.properties| do
      source 'custom.properties.erb'
      owner 'opencast'
      group 'opencast'
      variables({
        opencast_backend_http_port: 8080,
        hostname: private_hostname,
        nodename: nodename,
        elasticsearch_host: elasticsearch_host,
        elasticsearch_protocol: elasticsearch_protocol,
        elasticsearch_port: elasticsearch_port,
        local_workspace_root: local_workspace_root,
        shared_storage_root: shared_storage_root,
        admin_url: "#{public_admin_protocol}://#{public_admin_hostname}",
        rest_auth: rest_auth_info,
        admin_auth: admin_user_info,
        database: database_connection,
        engage_hostname: public_engage_hostname,
        engage_protocol: public_engage_protocol,
        capture_agent_monitor_url: capture_agent_monitor_url,
        live_monitor_url: live_monitor_url,
        job_maxload: nil,
        stack_name: stack_name,
        workspace_cleanup_period: 86400,
        distribution_type: distribution,
        cas_service: cas_service
      })
    end
  end
end

include_recipe 'oc-opsworks-recipes::configure-opencast-service'
include_recipe "oc-opsworks-recipes::monitor-opencast-daemon"
