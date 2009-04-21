# Config Setup
initializer 'config.rb', <<-'CODE'
yaml_config = YAML.load_file("#{RAILS_ROOT}/config/config.yml") || {}
CONFIG = (yaml_config['default'] || {}).symbolize_keys.merge((yaml_config[RAILS_ENV] || {}).symbolize_keys)
CODE

file 'config/config.yml', <<-'CODE'
default:

development:

production:

CODE

# HAML
gem "haml"
rake "gems:install", :sudo => true
run "haml --rails ."

# Clear the default index
run "rm public/index.html"

# Git Setup
file '.gitignore', <<-'CODE'
log/*.log
tmp/*
doc/app
doc/api
.DS_Store
db/*.db
db/*.sqlite3
config/database.yml
config/config.yml
Capfile
config/deploy.rb
config/deploy/*
CODE

# Git empty directories
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

# Repo commands
git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"
