class PaymentGroup

  constructor: () ->
    if $('#js-total_debt').html()
      @total_debt = parseFloat($('#js-total_debt').html().replace(',', '.'))
    @usd_cotization = if $('#js-usd_cotization').html() then parseFloat($('#js-usd_cotization').html().replace(',', '.')) else 1
    @bindEvents()

  bindEvents: () ->
    that           = @
    payment_method = $('#payment_payment_method')

    payment_method.on 'change', ->
      if (payment_method.find(':selected').val())
        that.resetFields()
        account_currency = payment_method.find(':selected').data('account_currency')
        payment_currency = $('#js-total_debt').data('payment_currency')

        p_to_p = (account_currency == 1) && (payment_currency == 'P')
        p_to_d = (account_currency == 1) && (payment_currency == 'D')
        d_to_d = (account_currency == 2) && (payment_currency == 'D')

        if (p_to_p)
            that.pesoToPeso(that)
        else if (p_to_d)
            that.pesoToDollar(that)
        else
            that.dollarToDollar(that)

      else
        $('#payment_total_payment').prop('readonly', true)

    $("input[name='payment[commission]']").on 'keyup', (e) =>
      commission = parseFloat($(e.target).val())
      iva        = commission * 0.21
      total      = commission + iva

      $("input[name='payment[commission_total]']").val(total.toFixed(2))
      $("input[name='payment[iva]']").val(iva.toFixed(2))


  resetFields: () ->
    $('#payment_total_payment').val('')
    $('#payment_cotization').val('')
    @notOk()

  pesoToPeso: (paymentGroup) ->
    paymentGroup.setCotization(1)
    $('#payment_total_payment').prop('readonly', false)

    if ($('#payment_partial_payment').is(':checked'))
      $('#js-btn-payment').prop('disabled', false)

    $('#payment_partial_payment').on 'change', ->
      if ($('#payment_partial_payment').is(':checked'))
        $('#js-btn-payment').prop('disabled', false)
      else
        $('#js-btn-payment').prop('disabled', true)

    $('#payment_total_payment').on 'keyup', ->
      unless ($('#payment_partial_payment').is(':checked'))
        value = parseFloat($(this).val()) || 0
        ig_retention = parseFloat($('#payment_ig_retention').val()) || 0
        paymentGroup.checkTotal((value + ig_retention).toFixed(2), paymentGroup)

  pesoToDollar: (paymentGroup) ->
    $('#payment_cotization').prop('readonly', false)
    $('#payment_total_payment').prop('readonly', true)
    $('#payment_cotization').on 'keyup', ->
      if !$(this).val()
        paymentGroup.setTotal(0)
      else
        cotization = parseFloat($(this).val().replace(',', '.')) || 1
        value      = parseFloat(paymentGroup.total_debt * cotization)
        retention  = (parseFloat($("#payment_ig_retention").val()) * cotization) || 0

        paymentGroup.setTotal(value - retention)
        paymentGroup.checkTotal(value, paymentGroup)

        if $("#js-pesoToDollarForNationalOperator").length > 0
          cotization = parseFloat($("#payment_cotization").val())
          $('#js-reminding_amount').html(parseFloat((value - retention) / cotization).toFixed(2))
          value_in_ars = parseFloat(value - retention).toFixed(2)
          $('#js-reminding_amount_in_ars').html(value_in_ars)

  dollarToDollar: (paymentGroup) ->
    $('#payment_cotization').unbind('keyup')
    paymentGroup.setCotization(paymentGroup.usd_cotization)
    paymentGroup.setTotal(paymentGroup.total_debt)
    $('#payment_total_payment').prop('readonly', true)
    paymentGroup.checkTotal(paymentGroup.total_debt, paymentGroup)

  setTotal: (value) ->
    $('#payment_total_payment').val(value.toFixed(2))

  setCotization: (value) ->
    $('#payment_cotization').val(value)

    if value == 1
      $('#payment_cotization').prop('readonly', true)
    else
      $('#payment_cotization').prop('readonly', false)

  checkTotal: (value, paymentGroup) ->
    if paymentGroup.total_debt <= value
      paymentGroup.ok()
    else
      paymentGroup.notOk()

  ok: () ->
    $('#js-debt_box').switchClass("bg-red", "bg-green", 100)
    $('#js-debt_box').effect('bounce')
    $('#js-btn-payment').prop('disabled', false)

  notOk: () ->
    $('#js-debt_box').switchClass("bg-green", "bg-red", 100)
    $('#js-btn-payment').prop('disabled', true)


$(document).on "ready turbolinks:load", ->
  if $(".national_payment_groups, .international_payment_groups, .refund_payment_groups, .payment_groups").length > 0
    new PaymentGroup()
