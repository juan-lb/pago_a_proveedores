App.ConfirmationBox =

  defaults:
    title: 'Atención'
    message: '¿Confirmar acción?'
    cancel_btn: 'Cancelar'
    confirm_btn: 'Confirmar'

  confirmDialog: (element) ->
    title       = element.data('title') || @defaults['title']
    message     = element.data('confirm') || @defaults['message']
    cancel_btn  = element.data('cancel-btn') || @defaults['cancel_btn']
    confirm_btn = element.data('confirm-btn') || @defaults['confirm_btn']

    element.data('confirm', null)

    bootbox.confirm
      title: title
      message: message
      buttons:
        cancel:
          label: cancel_btn
          className: 'btn-default'
        confirm:
          label: confirm_btn
          className: 'btn-danger'
      callback: (result) ->
        element.trigger 'click.rails' if result
        element.data('confirm', message)
        return

$(document).on 'confirm', (event) ->
  element = $(event.target)
  App.ConfirmationBox.confirmDialog(element)
  false
