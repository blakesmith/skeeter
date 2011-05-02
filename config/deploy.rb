$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.

require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, "1.9.2-p180"
set :rvm_type, :user  # Copy the exact line. I really mean :user here

set :user, "rails"
set :primary_server, "stiletto.blakesmith.me"

set :application, "skeeter"
set :repository,  "ssh://#{user}@#{primary_server}/home/blake/pubgit/#{application}.git"

set :scm, "git"
set :branch, "master"
set :deploy_to, "/home/rails/#{application}"
set :deploy_via, :remote_cache

set :runner, nil

role :app, "#{primary_server}"                          # This may be the same as your `Web` server

before('deploy:cleanup') { set :use_sudo, false }
before('deploy:setup') { set :use_sudo, false }
after 'deploy:update_code', 'bundler:bundle_new_release'

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
#    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
end

namespace :deploy do
  task :start_dispatcher do
    run "cd #{deploy_to}/current/bin && ruby dispatcher_controller.rb start"
  end

  task :start_workers do
    run "cd #{deploy_to}/current/bin; rvm use 1.9.2;  ruby worker_controller.rb start"
  end

  task :start_server do
    run "cd #{deploy_to}/current/bin && ruby skeeter_controller.rb start"
  end

  task :stop_dispatcher do
    run "cd #{deploy_to}/current/bin && ruby dispatcher_controller.rb stop"
  end

  task :stop_workers do
    run "cd #{deploy_to}/current/bin && ruby worker_controller.rb stop"
  end

  task :stop_server do
    run "cd #{deploy_to}/current/bin && ruby skeeter_controller.rb stop"
  end

  task :start do
    start_dispatcher
    start_workers
    start_server
  end

  task :stop do 
    stop_dispatcher
    stop_workers
    stop_server
  end

  task :restart do
    stop
    start
  end
end
