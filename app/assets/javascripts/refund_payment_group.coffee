class RefundPaymentGroup

  constructor: ->
    # Habilitar 'FakeMode' al clickear en 'Operar Devolución Ficticia'
    $('[data-behavior~=enableFakeMode]').on 'click', (event) =>
      @enableFakeMode(event)

    # Deshabilitar 'FakeMode' al clickear en 'Volver a Devolución Real'
    $('[data-behavior~=disableFakeMode]').on 'click', (event) =>
      @disableFakeMode(event)

    # Obtener con servicios con AJAX al elegir un operador
    $('#operator_id').on 'change', @getServiceRegisters

    # Resetear checkboxes al hacer click en tab 'Asieto de egreso'
    $('[data-behavior~=displayExpenditure]').on 'click', =>
      $("input[name='register_ids[]']").prop('checked', false)
      @resetSelectedServices()

    # Resetear cuenta bancaria al hacer click en 'Pago de reservas'
    $('[data-behavior~=displayServiceRegisters]').on 'click', ->
      $('#payment_bank_account').prop('selectedIndex', 0)

    # Mostrar modal de ayuda al hacer click en '?'
    $('[data-behavior~=displayHelp]').on 'click', @displayHelp


  enableFakeMode: (e) =>
    button = (e.target).closest('span')

    return if $(button).attr('disabled') == true

    $(button).attr 'disabled', true
    $('form.edit_payment')[0].reset()
    $('#js-fakeModeOptions').removeClass 'hidden'

    select        = $("#payment_payment_method")
    valid_options = "[value=460], [value=92], [value='']"

    select.prop('selectedIndex', 0)
    select.find('option').not(valid_options).hide()

  disableFakeMode: (e) =>
    select = $("#payment_payment_method")

    select.prop('selectedIndex', 0)
    select.find('option').show()

    $('#js-fakeModeOptions').addClass 'hidden'
    $('[data-behavior~=enableFakeMode]').attr 'disabled', false

    # Reset de tab 'Asiento de egreso'
    $('form.edit_payment')[0].reset()

    # Reset de tab 'Pago de reservas'
    $('#operator_id').val(null).trigger('change')
    $('#js-services').empty()
    $('#principal_reserve_id').empty()

  getServiceRegisters: =>
    id = $('#operator_id').val()

    return if id == null

    $.ajax
      url: "/service_registers.js?register_filter[operator_id]=#{id}"
      cache: false
      dataType: 'html'
      success: (data) =>
        $('#js-services').html data
        $('input[type=checkbox].js-serviceRegister').on 'click', (event) =>
          @sumSelectedServices()
          @updateReservesSelect(event)

  sumSelectedServices: =>
    ars = 0
    usd = 0

    $('input:checked.js-serviceRegister').each (i, input) ->
      if $(input).attr('data-currency') == 'AR$'
        ars += parseFloat($(input).attr('data-cost'))
      else
        usd += parseFloat($(input).attr('data-cost'))

    $('#js-selectedARS').text(Utilities.formatMoney(ars, 2, ''))
    $('#js-selectedUSD').text(Utilities.formatMoney(usd, 2, ''))

    @validateTotal(ars, usd)

  validateTotal: (ars, usd) ->
    submit     = $('#js-btn-payment')
    data       = $('#js-total_debt')
    total      = parseFloat data.data('total')
    cotization = parseFloat $('#payment_cotization').val()

    usd *= cotization
    selected = Math.round((ars + usd) * 100) / 100

    if data.data('currency') == 'P'
      submit.attr('disabled', selected >= total)
    else if data.data('currency') == 'D'
      submit.attr('disabled', selected >= total * cotization)

  updateReservesSelect: (e) =>
    select   = $('#principal_reserve_id')
    reserves = []
    options  = ''

    $('input:checked.js-serviceRegister').each (i, input) ->
      id = $(input).closest('tr').data('file-number')
      reserves.push id

    reserves = $.unique(reserves)

    while (reserve = reserves.shift()) != undefined
      options += "<option value='#{reserve}'>#{reserve}</option>"

    $('#principal_reserve_id').html options

  resetSelectedServices: ->
    $('#principal_reserve_id').empty()
    $('#js-selectedARS').text(Utilities.formatMoney(0, 2, ''))
    $('#js-selectedUSD').text(Utilities.formatMoney(0, 2, ''))

  displayHelp: ->
    $('#modal').find('.modal-content').html("<div class='modal-header'><h4 class='modal-title'><i class='fa fa-question-circle text-primary'></i> Ayuda</h4></div><div class='modal-body'><div class='row'><div class='col-md-12'><p>La funcionalidad de <b>devoluciones ficticias con compensación por pago de reservas</b> utiliza cuentas de ajuste (<b>AJUSTE</b> o <b>AJUSTE DÓLARES</b>) para devolver dinero de créditos y pagar con la misma cuenta débitos de otro operador.</p><p>La carga <b>asienta una devolución y un pago en Aptour</b> con la cuenta de ajuste seleccionada.</p><p>La única restricción de la funcionalidad es que <b>no puede utilizarse la cuenta AJUSTE DÓLARES para devolver o compensar servicios nominados en pesos</b>, ya sea créditos de devolución o débitos de compensación.</p></div></div></div>")
    $('#modal').modal()


$(document).on 'ready turbolinks:load', ->
  if $('.refund_payment_groups').length > 0
    new RefundPaymentGroup()
