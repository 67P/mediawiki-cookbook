#
# Cookbook Name:: mediawiki
# Recipe:: nginx
#

node.set_unless['php-fpm']['pools'] = []

include_recipe "php-fpm"
include_recipe 'php-fpm::repository' unless node['php-fpm']['skip_repository_install']

if node['php-fpm']['package_name'].nil?
  if platform_family?("rhel")
    php_fpm_package_name = "php-fpm"
  else
    php_fpm_package_name = "php5-fpm"
  end
else
  php_fpm_package_name = node['php-fpm']['package_name']
end

package php_fpm_package_name do
  action :install
end

if node['php-fpm']['service_name'].nil?
  php_fpm_service_name = php_fpm_package_name
else
  php_fpm_service_name = node['php-fpm']['service_name']
end

service "php-fpm" do
  service_name php_fpm_service_name
  supports :start => true, :stop => true, :restart => true, :reload => true
  action [ :enable, :start ]
end

php_fpm_pool "www" do
  enable false
end

php_fpm_pool "mediawiki" do
  listen "127.0.0.1:9002"
  user node['nginx']['user']
  group node['nginx']['group']
  listen_owner node['nginx']['user']
  listen_group node['nginx']['group']
  php_options node['mediawiki']['php_options']
  start_servers 5
  enable true
end

include_recipe "php::module_mysql"
include_recipe "nginx"

directory node["mediawiki"]["docroot_dir"] do
  user node['nginx']['user']
  group node['nginx']['group']
  recursive true
end
