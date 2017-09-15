if ($('#modal').data('bs.modal') or {}).isShown
  $('#modal').modal('hide')

# Eliminar filas de servicios agregados al pago
<% @registers_ids.each do |id| %>
$('#service-register-<%= id %>').remove()
<% end %>

# Actualizar totales de servicios
ars_deb  = 0
usd_deb  = 0
ars_cred = 0
usd_cred = 0

$(".js-debit").each (i, input) ->
  if $(input).attr("data-currency") == "AR$"
    ars_deb += parseFloat($(input).attr("data-cost"))
  else
    usd_deb += parseFloat($(input).attr("data-cost"))

$(".js-credit").each (i, input) ->
  if $(input).attr("data-currency") == "AR$"
    ars_cred += parseFloat($(input).attr("data-cost"))
  else
    usd_cred += parseFloat($(input).attr("data-cost"))

$('#js-totalARS-debit').text  Utilities.formatMoney(ars_deb, 2, '')
$('#js-totalUSD-debit').text  Utilities.formatMoney(usd_deb, 2, '')
$('#js-totalARS-credit').text Utilities.formatMoney(ars_cred, 2, '')
$('#js-totalUSD-credit').text Utilities.formatMoney(usd_cred, 2, '')

# Actualizar tab de pago borrador
$('#js-panel_services').html('<%= j render partial: "services/panel_edit_services", locals: {payment_group: @presenter.payment_group.reload} %>')

App.service_registers.showPaymentGroupTab()
App.init()
$.AdminLTE.boxWidget.activate()

if $(".service_registers").length > 0
  App.service_registers = new App.ServiceRegisters
