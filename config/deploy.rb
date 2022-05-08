# config valid for current version and patch releases of Capistrano
lock "~> 3.17.0"

set :application, "Hoopers"
set :repo_url, "https://github.com/tomiswinner/Hoopers"

# Uncomment the following to require manually verifying the host key before first deploy.
set :ssh_options,{
  auth_methods: ['publickey'],
  keys: ['~/.ssh/practice-aws.pem']
} 

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, '2.6.3'

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 'config/master.key', '.env'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/ec2-user/Hoopers"

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids","tmp/uploads", "tmp/cache", "tmp/sockets", "public", "vendor"

# Default value for keep_releases is 5
set :keep_releases, 5

# puma
# set :puma_conf, "#{current_path}/config/puma/production.rb"

# Default branch is :master
set :branch, 'master'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }


