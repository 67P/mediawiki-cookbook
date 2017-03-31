::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

node.set_unless['mediawiki']['db']['pass'] = secure_password
node.save unless Chef::Config[:solo]

db = node["mediawiki"]["db"]

mysql_client "default" do
  action :create
end

mysql2_chef_gem "default" do
  action :install
end

mysql_service db["instance_name"] do
  port db["port"]
  initial_root_password db["root_password"]
  action [:create, :start]
end

socket = "/var/run/mysql-#{db['instance_name']}/mysqld.sock"

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

# Create new database
mysql_database db["name"] do
  connection mysql_connection_info
  action :create
end

# Create new user
mysql_database_user db["user"]  do
  connection mysql_connection_info
  password   db["pass"]
  action     :create
end

# Grant privilages to user
mysql_database_user db["user"] do
  connection    mysql_connection_info
  database_name db["name"]
  privileges    [:all]
  action        :grant
end
