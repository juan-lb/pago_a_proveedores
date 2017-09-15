# namespace :ig_retentions do
#   desc 'Update accumulated amount to include payment_amounts from 1/7/2016 to 6/7/2016'
#
#   task update: :environment do
#
#     ig = IgRetention.all
#
#     ig.each do |i|
#       i.accumulated_in_cents = 0
#       i.save
#     end
#
#     payment_groups = get_payment_groups()
#     operator_ids = payment_groups.collect { |pg| pg.operator_id }
#
#     operator_ids.uniq.each do |id|
#       ig_ret = IgRetention.find_by(id_ope: id)
#
#       unless ig_ret.nil?
#         payments = payment_groups.select { |pg| pg.operator_id == id }
#         ope = payments.first.operator_name
#         accum = accumulated_for_operator(payments)
#
#         ig_ret.update_attributes(
#             month: Time.zone.today.beginning_of_month,
#             accumulated: accum
#         )
#       end
#     end
#
#     update_specific_operators()
#   end
#
#   def get_payment_groups
#     from = Date.parse("2016-07-01")
#     to   = Date.parse("2016-07-07")
#     payment_groups = PaymentGroup.joins(:payment).where('payments.payment_date BETWEEN ? AND ?', from, to).closed
#     payment_groups = payment_groups.select { |pg| pg.operator.ret_ganan }
#     payment_groups
#   end
#
#   def accumulated_for_operator(payment_groups)
#     accumulated = payment_groups.reduce(0) do |sum, pg|
#       total = pg.debts_amount + pg.credits_amount
#       sum + total
#     end
#   end
#
#   # - Los pagos que se hicieron el 1/7/2016 usando el sistema viejo de aptour
#   def update_specific_operators
#     month = Time.zone.today.beginning_of_month
#
#     ig_ret = IgRetention.find_by(id_ope: 196)
#     unless ig_ret.nil? || !Operator.find(196).ret_ganan
#       puts "De Marado: #{ig_ret.accumulated}"
#       total = 26637.30 + ig_ret.accumulated
#       puts "De Marado: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 1481)
#     unless ig_ret.nil? || !Operator.find(1481).ret_ganan
#       puts "My Beds: #{ig_ret.accumulated}"
#       total = 54621.31 + ig_ret.accumulated
#       puts "My Beds: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 664)
#     unless ig_ret.nil? || !Operator.find(664).ret_ganan
#       accum = 39862.46 + 8779.14
#       puts "Solvera: #{ig_ret.accumulated}"
#       total = accum + ig_ret.accumulated
#       puts "Solvera: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 126)
#     unless ig_ret.nil? || !Operator.find(126).ret_ganan
#       puts "Vanguard: #{ig_ret.accumulated}"
#       total = 52665.75 + ig_ret.accumulated
#       puts "Vanguard: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 248)
#     unless ig_ret.nil? || !Operator.find(248).ret_ganan
#       puts "Sheraton Salta: #{ig_ret.accumulated}"
#       total = 16943.97 + ig_ret.accumulated
#       puts "Sheraton Salta: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 382)
#     unless ig_ret.nil? || !Operator.find(382).ret_ganan
#       puts "Kosten Aike: #{ig_ret.accumulated}"
#       total = 3513.84 + ig_ret.accumulated
#       puts "Kosten Aike: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 1571)
#     unless ig_ret.nil? || !Operator.find(1571).ret_ganan
#       puts "La Boheme: #{ig_ret.accumulated}"
#       total = 11352.60 + ig_ret.accumulated
#       puts "La Boheme: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#
#
#     ig_ret = IgRetention.find_by(id_ope: 935)
#     unless ig_ret.nil? || !Operator.find(935).ret_ganan
#       puts "Grand Crucero Hotel: #{ig_ret.accumulated}"
#       total = 272.87 + ig_ret.accumulated
#       puts "Grand Crucero hotel: #{total}"
#       ig_ret.update_attributes(month: month, accumulated: total)
#     end
#   end
# end