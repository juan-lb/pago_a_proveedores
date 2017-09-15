# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :domain, '10.0.0.15'
set :deploy_to, '/aplications/pago_a_proveedores/staging'
set :branch, ENV['branch'] || 'develop'
set :rails_env, 'staging'
set :supervisor_id, '4012-Pago-a-proveedores'

