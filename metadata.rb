name             'mediawiki'
maintainer       'pulsation'
license          'BSD'
description      'Installs/Configures mediawiki'
long_description 'Installs/Configures mediawiki'
version          '0.3.0'

depends          'apache2'
depends          'php'
depends          'mysql'
depends          'database'
depends          'nginx'
depends          'mysql2_chef_gem'
depends          'php-fpm'

attribute 'mediawiki/version',
				:display_name	=> "Mediawiki version",
				:type 				=> "string",
				:required 		=> "recommended"

attribute 'mediawiki/database/name',
				:display_name	=> "Database name",
				:type 				=> "string",
				:required 		=> "optional"

attribute 'mediawiki/database/user',
				:display_name	=> "Database user",
				:type 				=> "string",
				:required 		=> "optional"

attribute 'mediawiki/database/password',
				:display_name	=> "Database password",
				:type 				=> "string",
				:required 		=> "optional"

attribute 'mediawiki/server_name',
				:display_name	=> "Server name",
				:type					=> "string",
				:required			=> "recommended"

attribute 'mediawiki/sciptpath',
				:display_name => "Script path",
				:type					=> "string",
				:required			=> "optional"

attribute 'mediawiki/admin_user',
				:display_name	=> "Admin user",
				:type					=> "string",
				:required			=> "recommended"

attribute 'mediawiki/admin_password',
				:display_name	=> "Admin password",
				:type					=> "string",
				:required			=> "recommended"

recipe "mediawiki::default", "Installs/Configures mediawiki"

supports "centos"
supports "debian"
