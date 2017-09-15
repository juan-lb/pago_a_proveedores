namespace :import do
  desc 'Ejecuta la importacion'
  task :execute => :environment do
    Import.remote_import
  end
end
