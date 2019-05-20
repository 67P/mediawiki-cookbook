::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

package('libmysqlclient-dev') { action :nothing }.run_action(:install)

build_essential 'mediawiki' do
  compile_time true
end

node.normal['mediawiki']['db']['pass'] = secure_password
node.save unless Chef::Config[:solo]

db = node["mediawiki"]["db"]

package %w(mysql-client mysql-server)

service 'mysql' do
  action [:enable, :start]
end

# Create database
execute "create #{db["name"]} db" do
  command "mysql -e \"CREATE DATABASE IF NOT EXISTS #{db["name"]};\""
  user "root"
end

# Create user
execute "create #{db["user"]} user" do
  command "mysql -e \"CREATE USER IF NOT EXISTS '#{db["user"]}'@'localhost' IDENTIFIED BY '#{db["pass"]}'; GRANT ALL PRIVILEGES ON #{db["name"]}.* to '#{db["user"]}'@'localhost'; FLUSH PRIVILEGES;\""
  sensitive true
  user "root"
end
