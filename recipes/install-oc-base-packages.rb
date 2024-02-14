# Cookbook Name:: oc-opsworks-recipes
# Recipe:: install-oc-base-packages

::Chef::Recipe.send(:include, MhOpsworksRecipes::RecipeHelpers)

include_recipe "oc-opsworks-recipes::update-package-repo"

packages = %Q|rh-mysql57 postfix mailx tesseract libwebp 
  java-11-openjdk java-11-openjdk-devel java-11-openjdk-headless
  cyrus-sasl-plain cyrus-sasl-lib cyrus-sasl|

install_package(packages)

include_recipe 'maven'

# create symlink in common system path as deploy operations don't seem to source
# The $PATH settings the maven cookbook creates in '/etc/profile.d/maven.sh'
# Note: this is a feature of later versions of the maven cookbook
if node['maven']['setup_bin']
  link '/usr/bin/mvn' do
    to "#{node['maven']['m2_home']}/bin/mvn"
  end
end

include_recipe "oc-opsworks-recipes::clean-up-package-cache"
