require 'mina/multistage'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'
require 'mina/whenever'

set :user, 'aeroadm'
set :repository, 'http://takedown:k4K1-aero@git.aero.tur.ar/mszeinfeld/prevision_de_pago.git'
set :whenever_name, "pago_a_proveedores_#{rails_env}"

set :term_mode, nil

set :rvm_path, '/home/aeroadm/.rvm/scripts/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, %w(public/uploads config/database.yml config/secrets.yml config/initializers/settings.rb log)

# Optional settings:

#   set :port, '30000'     # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  invoke :"rvm:use[ruby-2.3.0@pago_a_proveedores]"
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task setup: :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/config/initializers"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config/initializers"]

  queue! %[touch "#{deploy_to}/#{shared_path}/config/initializers/settings.rb"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/database.yml"]
  queue! %[touch "#{deploy_to}/#{shared_path}/config/secrets.yml"]

  queue  %[echo "-----> Be sure to edit '#{deploy_to}/#{shared_path}/config/database.yml' and 'secrets.yml'"]

  # queue %[
  #   repo_host=`echo $repo | sed -e 's/.*@//g' -e 's/:.*//g'` &&
  #   repo_port=`echo $repo | grep -o ':[0-9]*' | sed -e 's/://g'` &&
  #   if [ -z "${repo_port}" ]; then repo_port=22; fi &&
  #   ssh-keyscan -p $repo_port -H $repo_host >> ~/.ssh/known_hosts
  # ]
end

desc "Deploys the current version to the server."
task deploy: :environment do
  to :before_hook do
    # Put things to run locally before ssh
  end

  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_create' #Esta linea se puede remover despues del primer deploy exitoso
    invoke :'rails:db_migrate:force'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue! 'echo "-----> Supervisor Restart"'
      queue! "sudo supervisorctl restart #{supervisor_id}"
      invoke :'whenever:update' if rails_env == 'production'
    end
  end
end

namespace :log do
  desc 'Muestra logs del servidor'
  task :unicorn do
    queue "tail -f #{deploy_to}/#{shared_path}/log/unicorn.stderr.log #{deploy_to}/#{shared_path}/log/unicorn.stdout.log"
  end

  desc 'Muestra logs de la aplicacion'
  task :app do
    queue "tail -f #{deploy_to}/#{shared_path}/log/#{rails_env}.log"
  end
end



namespace :db do
  task :clone do
    database = "pago_a_proveedores_#{rails_env}"
    dump_file = "/tmp/#{database}.sql"

    # DUMP EN EL SERVIDOR
    isolate do
      queue 'export MYSQL_PWD=opodpd777'
      queue "mysqldump -u administration -h 10.0.0.100 #{database} > #{dump_file}"
      queue "gzip -f #{dump_file}"

      mina_cleanup!
    end

    # LOCAL
    %x[scp aeroadm@#{domain}:#{dump_file}.gz .]
    %x[gunzip -f #{database}.sql.gz]

    %x[RAILS_ENV=development bundle exec rake db:drop db:create]
    %x[mysql -u root -p prevision_de_pago_development < #{database}.sql]
    %x[rm #{database}.sql]
  end
end
