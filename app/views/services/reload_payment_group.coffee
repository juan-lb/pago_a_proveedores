if $('#modal').is(':visible')
  $('#modal').modal 'hide'

$('#js-panel_services').html('<%= j render partial: "services/panel_edit_services", locals: { payment_group: @service.payment_group} %>')

App.init()
