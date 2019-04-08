#
# Cookbook Name:: mediawiki
# Recipe:: nginx
#

node.default['php-fpm']['pools'] = []
node.override['php-fpm']['package_name'] = "php-fpm"
node.override['php-fpm']['service_name'] = "php7.2-fpm"
node.override['php-fpm']['conf_dir'] = "/etc/php/7.2/fpm/conf.d"
node.override['php-fpm']['pool_conf_dir'] = "/etc/php/7.2/fpm/pool.d"
node.override['php-fpm']['conf_file'] = "/etc/php/7.2/fpm/php-fpm.conf"

include_recipe "php-fpm"
include_recipe 'php-fpm::repository' unless node['php-fpm']['skip_repository_install']
include_recipe "php-fpm::install"

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

include_recipe "nginx"

directory node["mediawiki"]["docroot_dir"] do
  user node['nginx']['user']
  group node['nginx']['group']
  recursive true
end
