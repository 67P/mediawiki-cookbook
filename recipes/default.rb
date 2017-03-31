#
# Cookbook Name:: mediawiki
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"

include_recipe "php::default"

if node['platform'] == 'ubuntu' and node['platform_version'] >= '16.04'
  # APC is now apcu in PHP 7
  include_recipe "php::module_apcu"
  # Dependency
  package "php7.0-mbstring"
else
  include_recipe "php::module_apc"
end
include_recipe "php::module_mysql"

include_recipe "mediawiki::database"

# Download mediawiki tarball
remote_file "#{Chef::Config[:file_cache_path]}/#{node['mediawiki']['tarball']['name']}" do
  source node['mediawiki']['tarball']['url']
  notifies :run, "bash[extract_mediawiki]", :immediately
end

# Extract mediawiki tarball
bash "extract_mediawiki" do
  user "root"
  cwd node["mediawiki"]["docroot_dir"]
  code "tar -zxf #{Chef::Config[:file_cache_path]}/#{node['mediawiki']['tarball']['name']}; chown -R #{node['nginx']['user']}:#{node['nginx']['group']} #{node['mediawiki']['docroot_dir']}"
  action :nothing
end

# Additional packages
case node["platform_family"]
when "rhel"
  package "php-xml"
  package "libicu-devel"
when "debian"
  package "libicu-dev"
end

if platform?('ubuntu') && node[:platform_version].to_f < 16.04
  # bundled with PHP since version 5.3
  php_pear "intl" do
    action :install
  end
end

# Configure mediawiki database
bash "configure_mediawiki_database" do
  user node["nginx"]["user"]
  cwd node["mediawiki"]["webdir"]
  code "php maintenance/install.php" +
    " --pass '" + node["mediawiki"]["admin_password"] +
    "' --dbname '" + node["mediawiki"]["db"]["name"] +
    "' --dbpass '" + node["mediawiki"]["db"]["pass"] +
    "' --dbuser '" + node["mediawiki"]["db"]["user"] +
    "' --server '" + node["mediawiki"]["server"] +
    "' --scriptpath '" + node["mediawiki"]["scriptpath"] +
    "' --lang '" + node["mediawiki"]["language_code"] +
    "' '" + node["mediawiki"]["site_name"] + "' '" + node["mediawiki"]["admin_user"] + "'"
  not_if { File.exist? "#{node["mediawiki"]["webdir"]}/LocalSettings.php" }
  action :run
end

file "#{node["mediawiki"]["webdir"]}/LocalSettings.php" do
  mode "0640"
  owner node["nginx"]["user"]
  group node["nginx"]["group"]
end
