namespace :payment_groups do

  desc 'Marca flag in_euros de aquellos pagos que tienen servicios en euros'
  task :mark_in_euros_flag => :environment do
    records = PaymentGroup.closed.select { |each| each.has_euros? }
    records.each { |each| each.update in_euros: true, updated_at: each.updated_at }
    puts "#{records.count} pagos modificados."
  end

end
