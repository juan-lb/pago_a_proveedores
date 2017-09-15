timeout 1200

app_dir = File.expand_path("../..", __FILE__)
# Logging
stderr_path "#{app_dir}/log/unicorn.stderr.log"
stdout_path "#{app_dir}/log/unicorn.stdout.log"
