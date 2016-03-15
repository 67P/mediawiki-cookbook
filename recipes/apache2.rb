include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"

# Add virtualhost
web_app "mediawiki" do
  server_name node["mediawiki"]["server_name"]
  docroot node["mediawiki"]["webdir"]
end

