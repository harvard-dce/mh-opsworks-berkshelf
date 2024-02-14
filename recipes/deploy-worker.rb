# Cookbook Name:: oc-opsworks-recipes
# Recipe:: deploy-worker

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
Chef::Provider::Deploy::Revision.send(:include, MhOpsworksRecipes::DeployHelpers)

opencast_repo_root = node[:opencast_repo_root]
local_workspace_root = get_local_workspace_root
storage_info = get_storage_info
shared_storage_root = get_shared_storage_root
rest_auth_info = get_rest_auth_info
admin_user_info = get_admin_user_info
stack_name = stack_shortname

capture_agent_monitor_url = node.fetch(
  :capture_agent_monitor_url, 'http://example.com/monitor_url'
)

immersive_classroom_url = node.fetch(
  :immersive_classroom_url, ''
)

immersive_classroom_engage_id = get_immersive_classroom_engage_id

git_data = node[:deploy][:opencast][:scm]
git_revision = git_data.fetch(:revision, 'master')
oc_prebuilt_artifacts = node.fetch(:oc_prebuilt_artifacts, {})
use_prebuilt_oc = is_truthy(oc_prebuilt_artifacts[:enable])

public_engage_hostname = get_public_engage_hostname
public_engage_protocol = get_public_engage_protocol
public_admin_hostname = get_public_admin_hostname
public_admin_protocol = get_public_admin_protocol
private_hostname = node[:opsworks][:instance][:private_dns_name]
nodename = node[:opsworks][:instance][:hostname]
private_admin_hostname = get_private_admin_hostname

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
      install_prebuilt_oc(oc_prebuilt_artifacts[:bucket], git_revision, :worker, most_recent_deploy)
    else
      maven_build_for(:worker, most_recent_deploy)
    end

    # Copy in the configs as distributed in the git repo
    # Some services will be further tweaked by templates
    copy_files_into_place_for(:worker, most_recent_deploy)

    install_init_scripts(most_recent_deploy, opencast_repo_root)
    install_opencast_log_configuration(most_recent_deploy)
    install_opencast_log_management
    install_multitenancy_config(most_recent_deploy, public_admin_hostname, public_admin_protocol, public_engage_hostname, public_engage_protocol, stack_name, immersive_classroom_url, immersive_classroom_engage_id)

    # WORKER SPECIFIC
    set_service_registry_intervals(most_recent_deploy)
    # /WORKER SPECIFIC

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
        job_maxload: 4,
        stack_name: stack_name,
        workspace_cleanup_period: 0
      })
    end
  end
end

include_recipe 'oc-opsworks-recipes::configure-opencast-service'
include_recipe "oc-opsworks-recipes::monitor-opencast-daemon"
