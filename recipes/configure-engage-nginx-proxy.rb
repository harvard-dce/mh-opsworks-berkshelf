# Cookbook Name:: oc-opsworks-recipes
# Recipe:: configure-engage-nginx-proxy

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

include_recipe "oc-opsworks-recipes::install-nginx"

shared_storage_root = get_shared_storage_root

public_engage_hostname = get_public_engage_hostname
public_engage_hostname_cors = get_public_engage_hostname_cors

engage_whitelist = get_engage_admin_allowed_hosts
# Use last 3 parts of Engage hostname domain for CORs domain check
# Escape the 2 dots to use as literal dot chars in regex
engage_domain_cors_regex = public_engage_hostname_cors[/((?=.)(\w+))((?:.)(\w+)){2}\z/].gsub(/\./, "\\.")

iframe_embed_whitelist = get_iframe_embed_allowed_hosts

ssl_info = node.fetch(:ssl, get_dummy_cert)
if cert_defined(ssl_info)
  create_ssl_cert(ssl_info)
  certificate_exists = true
end

worker_procs = get_nginx_worker_procs

file 'access whitelist' do
  path %Q|/etc/nginx/conf.d/admin_allow.conf|
  action :create
  owner 'root'
  content engage_whitelist.map{|ip| "allow #{ip};"}.join("\n") + "\n"
end

template 'nginx' do
  path %Q|/etc/nginx/nginx.conf|
  source 'nginx.conf.erb'
  variables({
    worker_procs: worker_procs
  })
end

template 'proxy' do
  path %Q|/etc/nginx/conf.d/default.conf|
  source 'engage-nginx-proxy-conf.erb'
  manage_symlink_source true
  variables({
    shared_storage_root: shared_storage_root,
    opencast_backend_http_port: 8080,
    certificate_exists: certificate_exists,
    public_engage_hostname: public_engage_hostname,
    engage_domain_cors_regex: engage_domain_cors_regex,
    iframe_embed_whitelist: iframe_embed_whitelist.join(" ")
  })
end

cookbook_file 'nginx-status.conf' do
  path %Q|/etc/nginx/conf.d/status.conf|
  owner "root"
  group "root"
  mode "644"
end

service 'nginx' do
  action [:enable, :start]
  supports start: true, stop: true, restart: true, reload: true
  start_command   "/bin/systemctl start nginx"
  stop_command   "/bin/systemctl stop nginx"
  restart_command  "/bin/systemctl restart nginx"
  reload_command  "/bin/systemctl reload nginx"
  subscribes :reload, "template[nginx]", :immediately
  subscribes :reload, "template[proxy]", :immediately
  # don't do these immediately as it will trigger a reload when the ssl key
  # is first written, which is prior to our config templates being generated
  # on initial node setup run
  subscribes :reload, "file[/etc/nginx/ssl/certificate.key]"
  subscribes :reload, "file[/etc/nginx/ssl/certificate.cert]"
  provider Chef::Provider::Service::Systemd
end
