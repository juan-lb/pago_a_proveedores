$('#payable_list').html('<%= j render partial: "service_registers/operators_table", locals: {ars_operators: @payable_manager.ars_operators, usd_operators: @payable_manager.usd_operators, total_ars: @payable_manager.total_ars_operators, total_usd: @payable_manager.total_usd_operators} %>')
$('#repeated_reserves').html('<%= j render partial: "service_registers/repeated_reserves", locals: {reserves: @payable_manager.repeated_reserves} %>')

App.init()

payable        = $('#payable_list')
select         = $('#reserve')
total_ars_html = payable.find('.js-total-ars')
total_usd_html = payable.find('.js-total-usd')

select.on 'change', ->
  total_ars = 0
  total_usd = 0
  reserve   = select.val()
  reserves  = $("[data-repeated_reserves*='#{reserve}']")
  rows      = payable.find('.js-payment')

  if reserve == ''
    rows.show()
    total_ars_html.text(Utilities.formatMoney(total_ars_html.data('total'), 2, ''))
    total_usd_html.text(Utilities.formatMoney(total_usd_html.data('total'), 2, ''))
  else
    reserves.each (index, each) ->
      if $(each).data('currency') == 'P'
        total_ars += parseFloat $(each).data('total')
      else if $(each).data('currency') == 'D'
        total_usd += parseFloat $(each).data('total')

    total_ars_html.text(Utilities.formatMoney(total_ars, 2, ''))
    total_usd_html.text(Utilities.formatMoney(total_usd, 2, ''))

    rows.hide()
    reserves.show()
