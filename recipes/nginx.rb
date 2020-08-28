#
# Cookbook Name:: mediawiki
# Recipe:: nginx
#

php_fpm_pool "mediawiki" do
  listen "127.0.0.1:9002"
  user node['nginx']['user']
  group node['nginx']['group']
  additional_config node['mediawiki']['php_options']
end

include_recipe "nginx"
