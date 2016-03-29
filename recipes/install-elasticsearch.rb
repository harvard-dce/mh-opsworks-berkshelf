# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-elasticsearch

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
::Chef::Recipe.send(:include, MhOpsworksRecipes::DeployHelpers)

elk_info = get_elk_info

es_major_version = elk_info[:es_major_version]
es_version = elk_info[:es_version]
es_cluster_name = elk_info[:es_cluster_name]
data_path = elk_info[:es_data_path]
es_heap_size = xmx_ram_for_this_node(0.5)
es_host = node['opsworks']['instance']['private_ip']
region = node['opsworks']['instance']['region']
stack_name = stack_shortname
enable_snapshots = elk_info[:es_enable_snapshots]
es_repo_bucket = "#{stack_name}-snapshots"

apt_repository 'elasticsearch' do
  uri "http://packages.elasticsearch.org/elasticsearch/#{es_major_version}/debian"
  components ['stable', 'main']
  keyserver 'ha.pool.sks-keyservers.net'
  key '46095ACC8548582C1A2699A9D27D666CD88E42B4'
end

apt_repository 'curator' do
  uri "http://packages.elastic.co/curator/3/debian"
  components ['stable', 'main']
  keyserver 'ha.pool.sks-keyservers.net'
  key '46095ACC8548582C1A2699A9D27D666CD88E42B4'
end

include_recipe "mh-opsworks-recipes::update-package-repo"
install_package("elasticsearch=#{es_version}")
install_package("python-elasticsearch-curator")

service 'elasticsearch' do
  supports :restart => true
  action :enable
end

{
  "kopf" => "lmenezes/elasticsearch-kopf/2.0",
  "cloud-aws" => "cloud-aws"
}.each do |dir_name, install_name|
  execute "install #{install_name} plugin" do
    not_if { ::Dir.exist?("/usr/share/elasticsearch/plugins/#{dir_name}") }
    command "/usr/share/elasticsearch/bin/plugin install -b #{install_name}"
    timeout 30
    retries 5
    retry_delay 10
  end
end

cookbook_file "kopf_settings" do
  path '/usr/share/elasticsearch/plugins/kopf/_site/kopf_external_settings.json'
  source "kopf_external_settings.json"
  owner 'root'
  group 'root'
  mode '644'
end

template '/etc/default/elasticsearch' do
  source 'elasticsearch-default.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables({
    heap_size: es_heap_size
  })
end

directory "create elasticsearch data dir" do
  path data_path
  owner 'elasticsearch'
  group 'elasticsearch'
  mode '755'
  recursive true
end

cookbook_file 'elasticsearch-logging.yml' do
  path '/etc/elasticsearch/logging.yml'
  owner 'root'
  group 'root'
  mode '644'
end

cookbook_file 'elasticsearch-logrotate.conf' do
  path '/etc/logrotate.d/elasticsearch'
  owner 'root'
  group 'root'
  mode '644'
end

template '/etc/elasticsearch/elasticsearch.yml' do
  source 'elasticsearch.yml.erb'
  owner 'root'
  group 'root'
  mode '644'
  variables({
    cluster_name: es_cluster_name,
    data_path: data_path,
    es_host: es_host,
    aws_region: region
  })
  notifies :restart, "service[elasticsearch]", :immediately
end

directory "template_dir" do
  path "/etc/elasticsearch/templates"
  owner 'root'
  group 'root'
  mode '755'
end

cookbook_file "useractions_template" do
  path "/etc/elasticsearch/templates/useractions.json"
  source "useractions.json"
  owner 'root'
  group 'root'
  mode '644'
end

http_request "put_template" do
  url "http://#{es_host}:9200/_template/dce-useractions"
  message lazy { ::File.read("/etc/elasticsearch/templates/useractions.json") }
  action :put
  retries 2
  retry_delay 30
end

if enable_snapshots
  ruby_block 'create snapshot bucket' do
    block do
      command = %Q(aws s3 mb s3://#{es_repo_bucket} --region #{region})
      Chef::Log.info command
      %x(#{command})
    end
  end

  http_request "register daily snapshot repo" do
    url "http://#{es_host}:9200/_snapshot/s3_daily"
    message %Q|
      {
        "type": "s3",
        "settings": {
          "bucket": "#{es_repo_bucket}",
          "region": "#{region}"
        }
      }
    |
    action :put
    retries 2
    retry_delay 30
    not_if "curl -f -s http://#{es_host}:9200/_snapshot/s3_daily > /dev/null"
  end

  # daily cumulative snapshots
  cron_d 'elasticsearch_daily_snapshot' do
    user 'elasticsearch'
    day '*'
    hour '3'
    minute '0'
    command %Q(curator --host #{es_host} snapshot --prefix "daily." --include_global_state False --repository s3_daily indices --regex '^[^\.].*$' 2>&1 | logger -t info)
    path '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
  end

end
