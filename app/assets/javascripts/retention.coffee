class Retention

  constructor: () ->
    @total_debt = parseFloat($('#js-total_debt').html().replace(',', '.')) if $('#js-total_debt').html()
    @bindEvents()

  bindEvents: () ->
    that     = @
    response = confirm("¿Confirmar edición de retenciones?")

    return unless response

    retention = $('#payment_ig_retention')

    retention.prop 'readonly', false
    retention.on 'change', ->
      elem       = @
      amount     = parseFloat($(elem).val())
      new_amount = parseFloat(that.total_debt - amount).toFixed(2)

      $('#js-reminding_amount').html(new_amount)

      if $("#js-pesoToDollarForNationalOperator").length > 0
        cotization     = parseFloat($("#payment_cotization").val())
        ars_new_amount = parseFloat(new_amount*cotization).toFixed(2)

        $('#js-reminding_amount_in_ars').html ars_new_amount
        $('#payment_total_payment').val       ars_new_amount


$ ->
  $("#js-edit_retention_amount").on 'click', ->
    new Retention()
