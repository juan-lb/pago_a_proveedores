class InternationalPaymentGroup

  constructor: () ->
    @total_debt = parseFloat($('#js-total_debt').html().replace(',', '.'))
    @bindEvents()

  bindEvents: () ->
    that   = @
    total  = $('#international_payment_group_total')
    submit = $('#js-btn_sent')

    # Deshabilitar submit si monto es menor en más de 0.5 que el débito
    total.on 'keyup change', ->
      amount = parseFloat(total.val())
      if amount + 0.5 < that.total_debt
        submit.prop('disabled', true)
      else
        submit.prop('disabled', false)

$(document).on "ready turbolinks:change", ->
  if $(".international_payment_groups.processed, .international_payment_groups.show").length > 0
    new InternationalPaymentGroup()
