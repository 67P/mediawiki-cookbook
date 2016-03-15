#
# Cookbook Name:: mediawiki
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
include_recipe "mysql::server"
include_recipe "database::mysql"

include_recipe "php::default"
include_recipe "php::module_apc"
include_recipe "php::module_mysql"

# Download mediawiki tarball
remote_file "#{Chef::Config[:file_cache_path]}/" + node['mediawiki']['tarball']['name'] do
  source node['mediawiki']['tarball']['url']
end

# Extract mediawiki tarball
bash "extract_mediawkiki" do
  user "root"
  cwd node["mediawiki"]["docroot_dir"]
  code "tar -zxf #{Chef::Config[:file_cache_path]}/" + node['mediawiki']['tarball']['name']
  action :run
end

# Database connection information
mysql_connection_info = {
  :host     => 'localhost',
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

# Create new database
mysql_database node['mediawiki']['database']['name'] do
  connection mysql_connection_info
  action :create
end

# Create new user
mysql_database_user node['mediawiki']['database']['user']  do
  connection mysql_connection_info
  password   node['mediawiki']['database']['password']
  action     :create
end

# Grant privilages to user
mysql_database_user node['mediawiki']['database']['user'] do
  connection    mysql_connection_info
  database_name node["mediawiki"]["database"]["name"]
  privileges    [:all]
  action        :grant
end

# Additional packages
case node["platform_family"]
when "rhel"
  package "php-xml"
  package "libicu-devel"
when "debian"
  package "libicu-dev"
end

php_pear "intl" do
  action :install
end

# Configure mediawiki database
bash "configure_mediawkiki_database" do
  user "root"
  cwd node["mediawiki"]["webdir"]
  code "php maintenance/install.php" +
    " --pass '" + node["mediawiki"]["admin_password"] +
    "' --dbname '" + node["mediawiki"]["database"]["name"] +
    "' --dbpass '" + node["mediawiki"]["database"]["password"] +
    "' --dbuser '" + node["mediawiki"]["database"]["name"] +
    "' --server '" + node["mediawiki"]["server"] +
    "' --scriptpath '" + node["mediawiki"]["scriptpath"] +
    "' --lang '" + node["mediawiki"]["language_code"] +
    "' '" + node["mediawiki"]["site_name"] + "' '" + node["mediawiki"]["admin_user"] + "'"
  action :run
end
