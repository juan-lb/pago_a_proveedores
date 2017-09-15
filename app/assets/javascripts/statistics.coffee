class Statistics

  constructor: () ->
    @bindEvents()

  bindEvents: ->
    # Inicializar TableSorter
    @init_tablesorter()

    # Inicializar inputs
    @init_inputs()

    # Animar carga al hacer click en 'Filtrar'
    $('[data-behavior~=filter_statistics]').on 'click', =>
      @show_loading_animation()

    # Totalizar al hacer click en el checkbox de pago
    $('.js-statisticsPaymentGroup input[type=checkbox]').on 'click', (e)=>
      @calculateSum $('.js-statisticsPaymentGroup:not(.filtered) input:checked')

    # Totalizar al hacer click en el checkbox general
    $('#checkbox_statistics').on 'click', (e)=>
      @select_all_payments $(e.target)


  init_tablesorter: ->
    $table = $('.tablesorter').tablesorter
      theme : "materialize",
      widthFixed: true,
      widgets : ["filter"]

      $('#js-paymentsListTable').on('apply.daterangepicker', ->
        $table.trigger 'search'
      )

  init_inputs: ->
    payments_table = $('#js-paymentsListTable')

    # Tabla de pagos
    payments_table.find('th').first().unbind()
    if payments_table.find('.tablesorter-filter').length == 6
      payments_table.find('.tablesorter-filter')[0].remove()
    payments_table.find('.tablesorter-filter').addClass('form-control')

    # Datepickers
    date_input = payments_table.find('.tablesorter-filter')[0]
    date_input.type = 'text'
    today = moment().add(1, 'days')
    $(date_input).daterangepicker
      ranges:
        'Última semana': [moment().subtract(7, 'days'), today]
        'Últimos 30 días': [moment().subtract(30, 'days'), today]
        'Último año': [moment().subtract(1, 'year').add(1,'day'), today]

    $('#js-selectDateRange').on 'change', @set_dates
    $('#js-selectDateRange2').on 'change', @set_dates

    # Modo de comparación
    $('[data-behavior~=enableComparisonMode]').on 'click', =>
      @enable_comparison_mode()
    $('[data-behavior~=disableComparisonMode]').on 'click', =>
      @disable_comparison_mode()


  show_loading_animation: ->
    $('.js-statisticsTable').remove()
    $('.js-loadingStatistics').removeClass('hidden')

  set_dates: ->
    input   = $(this)
    from    = input.parent().next().find('input')
    to      = input.parent().next().next().find('input')
    date    = new Date()
    to_date = null

    switch input.val()
      when 'lastWeek'
        date.setDate(date.getUTCDate() - 7)
      when 'lastMonth'
        date.setMonth(date.getUTCMonth() - 1)
      when 'lastYear'
        date.setYear(date.getUTCFullYear() - 1)
      when 'month'
        option  = input.find('option:selected')
        date    = new Date(option.data('year'),option.data('month')-1,1)
        to_date = new Date(option.data('year'),option.data('month'),0)

    $(from).datepicker('setDate', date)
    $(to).datepicker('setDate', to_date || new Date())

  enable_comparison_mode: ->
    $('.js-comparisonMode').removeClass 'hidden'
    $('.js-regularMode').addClass 'hidden'
    $('#js-periodLabel').text 'Periodo (inicio)'
    $('[data-behavior~=enableComparisonMode]').attr 'disabled', true

  disable_comparison_mode: ->
    $('.js-comparisonMode').find('input').val ''
    $('.js-comparisonMode').closest('form').submit()
    $('#js-filterBody').html "<h4 class='text-center text-primary'>Cargando...</h4>"

  calculateSum: (payments)->
    sum_ars = 0
    sum_usd = 0
    sum_eur = 0

    payments.each (index, checkbox)->
      item_total = parseFloat($(checkbox).closest('.js-statisticsPaymentGroup').data('total'))
      currency = $(checkbox).closest('.js-statisticsPaymentGroup').data('currency')

      switch currency
        when 'P' then sum_ars += item_total
        when 'D' then sum_usd += item_total
        when 'E' then sum_eur += item_total

    $('.js-selected-ars-sum').html Utilities.formatMoney(sum_ars)
    $('.js-selected-usd-sum').html Utilities.formatMoney(sum_usd)
    $('.js-selected-eur-sum').html Utilities.formatMoney(sum_eur)

  select_all_payments: (checkbox)->
    if checkbox.prop('checked') == true
      @calculateSum $('.js-statisticsPaymentGroup:not(.filtered)')
    else
      $('.js-selected-sum').html Utilities.formatMoney(0)


$(document).on "ready turbolinks:load", ->
  if $(".statistics").length > 0
    new Statistics()
