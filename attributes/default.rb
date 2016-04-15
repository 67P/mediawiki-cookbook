default["mediawiki"]["version"]              = "1.26.2"
default["mediawiki"]["docroot_dir"]          = "/var/www"
default["mediawiki"]["webdir"]               = "#{default["mediawiki"]["docroot_dir"]}/mediawiki-#{default["mediawiki"]["version"]}"
default["mediawiki"]["tarball"]["name"]      = "mediawiki-" + default["mediawiki"]["version"] + ".tar.gz"
default["mediawiki"]["tarball"]["url"]       = "https://releases.wikimedia.org/mediawiki/1.26/" + default["mediawiki"]["tarball"]["name"]
default["mediawiki"]["server_name"]          = "wiki.localhost"
default["mediawiki"]["scriptpath"]           = ""

default["mediawiki"]["server"]               = "http://" + default["mediawiki"]["server_name"]
default["mediawiki"]["site_name"]            = "my Wiki"
default["mediawiki"]["language_code"]        = "en"
default["mediawiki"]["admin_user"]           = "administrator"
default["mediawiki"]["admin_password"]       = "admin"

default["mediawiki"]["php_options"]          = { "php_admin_value[upload_max_filesize]" => "50M", "php_admin_value[post_max_size]" => "55M" }

default['mediawiki']['db']['root_password'] = 'my_root_password'
default['mediawiki']['db']['instance_name'] = 'default'
default['mediawiki']['db']['name'] = "mediawikidb"
default['mediawiki']['db']['user'] = "mediawikiuser"
default['mediawiki']['db']['pass'] = nil
default['mediawiki']['db']['prefix'] = 'wp_'
default['mediawiki']['db']['host'] = 'localhost'
default['mediawiki']['db']['port'] = '3307'  # Must be a string
default['mediawiki']['db']['charset'] = 'utf8'
default['mediawiki']['db']['collate'] = ''
