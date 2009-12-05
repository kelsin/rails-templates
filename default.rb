# Path to template folder
@template = "~/templates"

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

# Default controller for static pages
generate :controller, 'home', 'index'
run 'touch app/views/home/index.html.haml'

# Shoulda
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com'

# Formtastic
gem 'formtastic', :source => 'http://gemcutter.org/'

# Authlogic
gem 'authlogic'

# HAML
gem 'haml'

# Install gems
rake 'gems:install', :sudo => true

# Setup HAML
run 'haml --rails .'

# Setup Formtastic
generate :formtastic

# Setup Authlogic
generate :session, 'user_session'
generate :model, 'user', 'email:string', 'crypted_password:string', 'password_salt:string',
                 'persistence_token:string', 'single_access_token:string', 'perishable_token:string',
                 'login_count:integer', 'failed_login_count:integer',
                 'last_request_at:datetime', 'current_login_at:datetime', 'last_login_at:datetime',
                 'current_login_ip:string', 'last_login_ip:string'
generate :controller, 'users'
generate :controller, 'user_sessions'

# Fix up migration and run it
run 'sed -e "s/:email/:email, :null => false/"\
         -e "s/:crypted_password/:crypted_password, :null => false/"\
         -e "s/:password_salt/:password_salt, :null => false/"\
         -e "s/:persistence_token/:persistence_token, :null => false/"\
         -e "s/:single_access_token/:single_access_token, :null => false/"\
         -e "s/:perishable_token/:perishable_token, :null => false/"\
         -e "s/:login_count/:login_count, :null => false, :default => 0/"\
         -e "s/:failed_login_count/:failed_login_count, :null => false, :default => 0/"\
         -i "" db/migrate/*_create_users.rb'
rake 'db:migrate'

# Authlogic user model and controllers
file "app/models/user.rb", <<-END
class User < ActiveRecord::Base
  acts_as_authentic
end
END

run "cp #{@template}/*_controller.rb app/controllers/"

# Clear the default files that we don't want
run 'rm README'
run 'rm public/index.html'
run 'rm public/favicon.ico'
run 'rm -f public/javascripts/{prototype,controls,dragdrop,effects}.js'
run 'rm -f public/images/*'

# jRails
plugin 'jrails', :git => 'git://github.com/aaronchi/jrails.git'
run 'cp vendor/plugins/jrails/javascripts/*.js public/javascripts/'

# Reset stylesheet
run "cp #{@template}/reset.css public/stylesheets/"

# Default layout
run "cp #{@template}/application.html.haml app/views/layouts/"

# Two views for login and registration
file "app/views/users/new.html.haml", <<-END
%h2 Register
- semantic_form_for @user do |f|
  - f.inputs do
    = f.input :email
    = f.input :password
    = f.input :password_confirmation
  - f.buttons do
    = f.commit_button :label => 'Register and Login'
END

file 'app/views/user_sessions/new.html.haml', <<-END
%h2 Login
- semantic_form_for @user_session do |f|
  - f.inputs do
    = f.input :email
    = f.input :password
  - f.buttons do
    = f.commit_button :label => 'Login'
END

# Default routes
file "config/routes.rb", <<-END
ActionController::Routing::Routes.draw do |map|
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.resources :users
  map.resources :user_sessions

  map.root :controller => 'home'
 
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
END

# Git ignore setup
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
run 'touch tmp/.gitignore log/.gitignore vendor/.gitignore'
run 'cp config/database.yml config/database.yml.sample'
run 'cp config/config.yml config/config.yml.sample'

# Repo commands
git :init
git :add => '.'
git :commit => '-a -m "Initial commit"'
