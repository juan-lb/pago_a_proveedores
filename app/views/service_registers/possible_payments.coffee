$('#possible_payments_list').html('<%= j render partial: "service_registers/operators_table", locals: { ars_operators: @manager.ars_operators, usd_operators: @manager.usd_operators, total_ars: @manager.total_ars_operators, total_usd: @manager.total_usd_operators } %>')
App.init()
