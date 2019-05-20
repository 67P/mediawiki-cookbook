::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

package('libmysqlclient-dev') { action :nothing }.run_action(:install)

build_essential 'mediawiki' do
  compile_time true
end

chef_gem 'mysql2' do
  compile_time true
end

node.normal['mediawiki']['db']['pass'] = secure_password
node.save unless Chef::Config[:solo]

db = node["mediawiki"]["db"]

mysql_client "default" do
  version '5.7' if node[:platform_version].to_f == 18.04
  action :create
end

mysql_service db["instance_name"] do
  version '5.7' if node[:platform_version].to_f == 18.04
  port db["port"]
  initial_root_password db["root_password"]
  action [:create, :start]
end

socket = "/var/run/mysql/mysqld.sock"

if node['platform_family'] == 'debian'
  directory "/var/run/mysqld" do
    action :create
    owner  "mysql"
    group  "mysql"
  end
  link '/var/run/mysqld/mysqld.sock' do
    to socket
    not_if 'test -f /var/run/mysqld/mysqld.sock'
  end
elsif node['platform_family'] == 'rhel'
  link '/var/lib/mysql/mysql.sock' do
    to socket
    not_if 'test -f /var/lib/mysql/mysql.sock'
  end
end

# Database connection information
mysql_connection_info = {
  :host     => "localhost",
  :username => "root",
  :socket   => socket,
  :password => db["root_password"]
}

# Grant privilages to user
mysql_database_user db["user"] do
  connection    mysql_connection_info
  database_name db["name"]
  privileges    [:all]
  password      db["pass"]
  action        :grant
end

# Create new database
mysql_database db["name"] do
  connection mysql_connection_info
  action :create
end
