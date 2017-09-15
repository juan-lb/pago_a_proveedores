class App.ServiceRegisters

  constructor: () ->
    @bindEvents()
    @calculateSelectedServicesCost()
    @enableOrDisableSubmit("debit")
    @enableOrDisableSubmit("credit")
    @checkCurrency()
    @calculatePaymentGroupTotal()

  bindEvents: () ->
    $('[data-behavior~=addServiceToPaymentGroup-debit]').on 'click', =>
      @showPaymentGroupTab

    $('[data-behavior~=addServiceToPaymentGroup-credit]').on 'click', =>
      @showPaymentGroupTab

    $('input[type=checkbox].js-debit').on 'click', =>
      @calculateSelectedServicesCost()
      @enableOrDisableSubmit("debit")

    $('input[type=checkbox].js-credit').on 'click', =>
      @calculateSelectedServicesCost()
      @enableOrDisableSubmit("credit")

    @bindSelectAllEvent("credit")
    @bindSelectAllEvent("debit")

    $('#js-searchReserve').on 'keyup', (e) =>
      @filterServices(e)

    $('.js-searchRegister').on 'keyup', (e) =>
      @filterRegisters(e)

    $('[data-behavior~=exportExcel]').on 'click', (event) =>
      @exportExcel(event)

    table = $('#services_table')
    if table.length > 0
      App.make_sortable_table table

  bindSelectAllEvent: (type)->
    $(document).on 'click', "[data-behavior~=selectAllRegisters-#{type}]", (e) =>
      submit = $("[data-behavior~=addServiceToPaymentGroup-#{type}]")

      if $(e.target).prop("checked") == true
        submit.removeAttr("disabled")
        $("#js-selectedARS-#{type}").text($("#js-totalARS-#{type}").text())
        $("#js-selectedUSD-#{type}").text($("#js-totalUSD-#{type}").text())
      else
        submit.attr("disabled", true)
        $("#js-selectedARS-#{type}").text(Utilities.formatNumber(0))
        $("#js-selectedUSD-#{type}").text(Utilities.formatNumber(0))

  showPaymentGroupTab: ->
    registers_panel = $('#js-panel_service_registers')
    services_panel  = $('#js-panel_services')

    services_panel.removeClass('hidden').addClass('col-md-3')
    services_panel.addClass('col-md-3')
    registers_panel.removeClass('col-md-12').addClass('col-md-9')

    $('#js-full_view_btn i').toggleClass('fa-indent fa-outdent')

  hidePaymentGroupTab: ->
    registers_panel = $('#js-panel_service_registers')
    services_panel  = $('#js-panel_services')

    services_panel.removeClass('col-md-3').addClass('hidden')
    registers_panel.removeClass('col-md-9').addClass('col-md-12')

    $('#js-full_view_btn i').toggleClass('fa-indent fa-outdent')

  calculateSelectedServicesCost: ->
    ars_cost_debits   = 0
    usd_cost_debits   = 0
    ars_cost_credits  = 0
    usd_cost_credits  = 0

    $("input:checked.js-debit").each (i, input) ->
      if $(input).attr("data-currency") == "AR$"
        ars_cost_debits += parseFloat($(input).attr("data-cost"))
      else
        usd_cost_debits += parseFloat($(input).attr("data-cost"))

    $("input:checked.js-credit").each (i, input) ->
      if $(input).attr("data-currency") == "AR$"
        ars_cost_credits += parseFloat($(input).attr("data-cost"))
      else
        usd_cost_credits += parseFloat($(input).attr("data-cost"))

    $('#js-selectedARS-debit').text(Utilities.formatMoney(ars_cost_debits, 2, ''))
    $('#js-selectedUSD-debit').text(Utilities.formatMoney(usd_cost_debits, 2, ''))
    $('#js-selectedARS-credit').text(Utilities.formatMoney(ars_cost_credits, 2, ''))
    $('#js-selectedUSD-credit').text(Utilities.formatMoney(usd_cost_credits, 2, ''))

  enableOrDisableSubmit: (type)->
    submit = $("[data-behavior~=addServiceToPaymentGroup-#{type}]")
    checked_check_boxes = $("input:checked.js-#{type}")

    if checked_check_boxes != null && checked_check_boxes.size() > 0
      submit.removeAttr("disabled")
    else
      submit.attr("disabled", true)

  checkCurrency: ->
    payment = $("#js-panel_edit_services")
    return if payment.length == 0

    payment_currency = $(payment).data("payment_currency")
    ars_count        = $("[data-currency~=P]").size()
    usd_count        = $("[data-currency~=D]").size()

    actions_tag = $("#js-paymentCurrencyActions")

    if @is_payment_invalid(payment_currency, usd_count, ars_count)
      errors_tag  = $("#js-paymentCurrencyErrors")

      $("#js-submitPayment").attr("disabled", true)
      errors_tag.text("¡Error de monedas! Seleccionar solución")
      actions_tag.removeClass("hidden")
    else
      actions_tag.addClass("hidden")

  is_payment_invalid: (currency, usd_count, ars_count) ->
    (currency == "AR$" && usd_count > 0) || (currency == "U$D" && ars_count > 0)


  calculatePaymentGroupTotal: ->
    payment = $("#js-panel_edit_services")
    return if payment.length == 0

    payment_currency = $(payment).data("payment_currency")
    payment_total    = $("#js-paymentTotal")

    ars_cost = 0
    usd_cost = 0

    $(".js-editableService").each ->
      service_cost = parseFloat($(this).data("cost"))
      if $(this).data("currency") == "P"
        ars_cost += service_cost
      else
        usd_cost += service_cost

    if payment_currency == "AR$"
      payment_total.text(Utilities.formatNumber(ars_cost))
    else
      payment_total.text(Utilities.formatNumber(usd_cost))

  filterServices: (e) =>
    file_number = $(e.target).val()

    if file_number == ''
      $('.js-editableService').removeClass 'hidden'
      return

    $('.js-editableService').addClass 'hidden'

    services = $("[data-reserve^='#{file_number}']")
    return unless services.length > 0

    services.removeClass 'hidden'

  filterRegisters: (e) =>
    input       = $(e.target)
    table       = input.closest('table')
    file_number = input.val()
    registers   = table.find('.js-row')

    if file_number == ''
      registers.removeClass 'hidden'
      return

    registers.addClass 'hidden'

    matches = table.find(".js-row[data-reserve^=#{file_number}]")
    return unless matches.length > 0

    matches.removeClass 'hidden'

  exportExcel: (e) =>
    form = $(e.target).closest('form')

    if form.find('input[type=checkbox]:checked').length == 0
      alert = new App.Alert()
      alert.alert('Seleccione al menos un servicio.', 'alert-danger')
      return

    original_action = form.attr('action')

    form.attr('action', '/service_registers/export_excel.xlsx')
    form.data('remote', false)

    form.submit()

    form.attr('action', original_action)
    form.data('remote', true)


$(document).on "ready turbolinks:change", ->
  if $('.service_registers').length > 0
    App.service_registers = new App.ServiceRegisters
