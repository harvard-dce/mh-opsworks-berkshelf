# Cookbook Name:: oc-opsworks-recipes
# Recipe:: install-opencast-job-metrics

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
include_recipe "oc-opsworks-recipes::update-python"

rest_auth_info = get_rest_auth_info
aws_instance_id = node[:opsworks][:instance][:aws_instance_id]
(private_admin_hostname, admin_attributes) = node[:opsworks][:layers][:admin][:instances].first
workers_layer_id = node[:opsworks][:layers][:workers][:id]
stack_id = node[:opsworks][:stack][:id]
stack_name = stack_shortname

pip_install("pyhorn")

cookbook_file 'queued_job_count_metric.sh' do
  path "/usr/local/bin/queued_job_count_metric.sh"
  owner "root"
  group "root"
  mode "755"
end

cron_d 'opencast_jobs_queued' do
  user 'custom_metrics'
  minute '*'
  command %Q(/usr/local/bin/queued_job_count_metric.sh "#{aws_instance_id}" "https://#{private_admin_hostname}" "#{rest_auth_info[:user]}" "#{rest_auth_info[:pass]}" 2>&1 | logger -t info)
  path '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
end
