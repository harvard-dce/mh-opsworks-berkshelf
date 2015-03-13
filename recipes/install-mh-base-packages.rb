# Cookbook Name:: mh-opsworks-recipes
# Recipe:: install-mh-base-packages

include_recipe "mh-opsworks-recipes::update-package-repo"

%w|maven2 openjdk-7-jdk openjdk-7-jre
  gstreamer0.10-plugins-base gstreamer0.10-plugins-good gstreamer0.10-tools
  gstreamer0.10-plugins-bad gstreamer0.10-plugins-ugly
  libglib2.0-dev mysql-client gzip tesseract-ocr|.each do |package_name|
    package package_name
  end

include_recipe "mh-opsworks-recipes::clean-up-package-installs"
