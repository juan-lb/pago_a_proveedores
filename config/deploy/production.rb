# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, '10.0.0.16'
set :deploy_to, '/aplications/pago_a_proveedores/production'
set :branch, ENV['branch'] || 'master'
set :rails_env, 'production'
set :supervisor_id, '4004-Pago-a-proveedores'
