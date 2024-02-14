# Cookbook Name:: oc-opsworks-recipes
# Recipe:: deploy-engage

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
Chef::Provider::Deploy::Revision.send(:include, MhOpsworksRecipes::DeployHelpers)

opencast_repo_root = node[:opencast_repo_root]
local_workspace_root = get_local_workspace_root
storage_info = get_storage_info
shared_storage_root = get_shared_storage_root
rest_auth_info = get_rest_auth_info
admin_user_info = get_admin_user_info
stack_name = stack_shortname

public_engage_hostname = get_public_engage_hostname_on_engage
public_engage_protocol = get_public_engage_protocol
private_hostname = node[:opsworks][:instance][:private_dns_name]
nodename = node[:opsworks][:instance][:hostname]
private_admin_hostname = get_private_admin_hostname
cas_enabled = node.fetch(:cas_enabled, false)
cas_service = (public_engage_protocol + "://" + public_engage_hostname + "/cas") if cas_enabled

capture_agent_monitor_url = node.fetch(
  :capture_agent_monitor_url, 'http://example.com/monitor_url'
)

immersive_classroom_url = node.fetch(
  :immersive_classroom_url, ''
)

immersive_classroom_engage_id = get_immersive_classroom_engage_id

auth_host = node.fetch(:auth_host, 'example.com')

# Porta auth system
porta_auto_conf = get_porta_auth_conf
porta_auto_enabled = porta_auto_conf[:enabled]
porta_auto_url = porta_auto_conf[:porta_auto_url]
porta_auto_cookie_name = porta_auto_conf[:cookie_name]
porta_auto_redirect_url = porta_auto_conf[:redirect_url]

# OPC-149 Other oc host for pub list merge
# The ignore-flag default value signals the config consumer
# That the value for the config was not intentionally set and should
# be ignored.
ignore_flag = 'IGNORE_ME'
other_oc_host = node.fetch(:other_oc_host, ignore_flag)
other_oc_prefother_series = node.fetch(:other_oc_prefother_series, ignore_flag)
other_oc_preflocal_series = node.fetch(:other_oc_preflocal_series, ignore_flag)
bug_report_email = node.fetch(:bug_report_email, "no_email_set")

# OPC-446 get helix googlesheet service config
helix_googlesheets_config = get_helix_googlesheet_config
helix_googlesheets_cred = helix_googlesheets_config[:cred]
helix_googlesheets_defaultdur_min = helix_googlesheets_config[:defaultduration_min]
helix_enabled = helix_googlesheets_config[:enabled]
helix_token = helix_googlesheets_config[:token]
helix_sheet_id = helix_googlesheets_config[:helix_sheet_id]
helix_email_enabled = helix_googlesheets_config[:change_notification_email_enabled]

## Engage specific

using_local_distribution = is_using_local_distribution?

production_management_email = node.fetch(
  :production_management_email, ''
)

# S3 distribution service
enable_s3 = !using_local_distribution
region = node.fetch(:region, 'us-east-1')
s3_distribution_bucket_name = get_s3_distribution_bucket_name
s3_distribution_base_url=get_base_media_download_url(public_engage_hostname)

# Configuration for searching transcripts
search_content_index_url = node.fetch(:transcript_search_endpoint, '')
search_content_lambda_name = node.fetch(:transcript_index_function, '')
search_content_enabled = ! search_content_index_url.empty? && ! search_content_lambda_name.empty?
## /Engage specific

git_data = node[:deploy][:opencast][:scm]
git_revision = git_data.fetch(:revision, 'master')
oc_prebuilt_artifacts = node.fetch(:oc_prebuilt_artifacts, {})
use_prebuilt_oc = is_truthy(oc_prebuilt_artifacts[:enable])

public_admin_hostname = get_public_admin_hostname
public_admin_protocol = get_public_admin_protocol

hostname = node[:opsworks][:instance][:hostname]

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
      install_prebuilt_oc(oc_prebuilt_artifacts[:bucket], git_revision, :presentation, most_recent_deploy)
    else
      maven_build_for(:presentation, most_recent_deploy)
    end

    # Copy in the configs as distributed in the git repo
    # Some services will be further tweaked by templates
    copy_files_into_place_for(:engage, most_recent_deploy)

    install_init_scripts(most_recent_deploy, opencast_repo_root)
    install_opencast_log_configuration(most_recent_deploy)
    install_opencast_log_management
    install_multitenancy_config(most_recent_deploy, public_admin_hostname, public_admin_protocol, public_engage_hostname, public_engage_protocol, stack_name, immersive_classroom_url, immersive_classroom_engage_id)
    install_smtp_config(most_recent_deploy)

    install_default_tenant_config(most_recent_deploy, cas_enabled, public_engage_hostname)
    install_porta_auth_service(
      most_recent_deploy, porta_auto_url, porta_auto_cookie_name, porta_auto_redirect_url, porta_auto_enabled
    )

    # ENGAGE SPECIFIC
    set_service_registry_intervals(most_recent_deploy)
    install_otherpubs_service_config(most_recent_deploy, opencast_repo_root, auth_host, other_oc_host, other_oc_prefother_series, other_oc_preflocal_series, bug_report_email)
    install_otherpubs_service_series_impl_config(most_recent_deploy)
    install_helix_googlesheets_service_config(most_recent_deploy, local_workspace_root,  helix_googlesheets_cred, helix_googlesheets_defaultdur_min, helix_enabled, helix_token, helix_sheet_id, helix_email_enabled)
    install_bug_report_email(most_recent_deploy, public_engage_hostname)
    install_aws_s3_distribution_service_config(most_recent_deploy, enable_s3, region, s3_distribution_bucket_name, s3_distribution_base_url)
    install_search_content_service_config(most_recent_deploy, search_content_enabled, region, s3_distribution_bucket_name, stack_name, search_content_index_url, search_content_lambda_name)
    # OPC-139 Oauth config
    install_oauthconsumerdetails_service_config(most_recent_deploy)
    # /ENGAGE SPECIFIC

    template %Q|#{most_recent_deploy}/etc/custom.properties| do
      source 'custom.properties.erb'
      owner 'opencast'
      group 'opencast'
      variables({
        opencast_backend_http_port: 8080,
        hostname: private_hostname,
        nodename: nodename,
        local_workspace_root: local_workspace_root,
        shared_storage_root: shared_storage_root,
        admin_url: "#{public_admin_protocol}://#{public_admin_hostname}",
        rest_auth: rest_auth_info,
        admin_auth: admin_user_info,
        database: database_connection,
        engage_hostname: public_engage_hostname,
        engage_protocol: public_engage_protocol,
        capture_agent_monitor_url: capture_agent_monitor_url,
        job_maxload: nil,
        stack_name: stack_name,
        workspace_cleanup_period: 0,
        production_management_email: production_management_email,
        cas_service: cas_service
      })
    end
  end
end

include_recipe 'oc-opsworks-recipes::configure-opencast-service'
include_recipe "oc-opsworks-recipes::monitor-opencast-daemon"
