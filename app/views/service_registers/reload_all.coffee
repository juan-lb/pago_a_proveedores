$('#js-panel_service_registers').html('<%= j render partial: "service_registers/service_register_tabs", locals: {presenter: @presenter} %>')

if ($('#modal').data('bs.modal') or {}).isShown
  $('#modal').modal('hide')

<% if @presenter.payment_group %>

$('#js-panel_services').html('<%= j render partial: "services/panel_edit_services", locals: {payment_group: @presenter.payment_group.reload} %>')
App.service_registers.showPaymentGroupTab()

<% else %>

$('#js-panel_edit_services').remove()
App.service_registers.hidePaymentGroupTab()

<% end %>

App.init() # Para reactivar los checkboxes
$.AdminLTE.boxWidget.activate()
App.service_registers = new App.ServiceRegisters unless $(".service_registers").length == 0
