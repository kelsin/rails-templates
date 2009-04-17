# Config Setup
initializer 'config.rb', <<-'CODE'
CONFIG = YAML.load_file("#{RAILS_ROOT}/config/config.yml") || {}
CONFIG = (CONFIG['default'] || {}).symbolize_keys.merge((CONFIG[RAILS_ENV] || {}).symbolize_keys)
CODE

file 'config/config.yml', <<-'CODE'
default:

development:

production:

CODE

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
CODE

# Git empty directories
run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
run "cp config/database.yml config/example_database.yml"

# Repo commands
git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"
