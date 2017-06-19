# Cookbook Name:: oc-opsworks-recipes
# Recipe:: configure-nginx-proxy

include_recipe "oc-opsworks-recipes::update-package-repo"
::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)
install_package('nginx')

install_nginx_logrotate_customizations

# The template path variable cannot be a get, must be saved locally first
body_temp_path = get_nginx_body_temp_path

template %Q|/etc/nginx/sites-enabled/default| do
  source 'nginx-proxy.conf.erb'
  manage_symlink_source true
  variables({
    opencast_backend_http_port: 8080,
    body_temp_path: body_temp_path
  })
end

# create path for nginx to buffer large uploads, the get can be called directly
directory get_nginx_body_temp_path do
  action :create
  owner 'www-data'
  group 'admin'
  mode '755'
  recursive true
end

directory '/etc/nginx/proxy-includes' do
  owner 'root'
  group 'root'
end

execute 'service nginx reload'
