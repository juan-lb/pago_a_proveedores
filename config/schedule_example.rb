# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "#{path}/log/cron.log"
set :environment, 'development' 
#
# every 1.day, :at => '4:30 am' do
#   command "curl localhost:3000/imports/remote_load"
# end
#
every 1.day, :at => '4:30 am' do
  #runner "Import.remote_import"
  rake "import:execute"
end

# Learn more: http://github.com/javan/whenever
