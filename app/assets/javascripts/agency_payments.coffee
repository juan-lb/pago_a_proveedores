class AgencyPayments

  constructor: () ->
    # Inicialización de TableSorter
    @init_tablesorter()

    # Cargar animación al hacer click en 'Reintentar'
    $('[data-behavior~=retry]').on 'click', @animate_loading

    # Mostrar animación de carga
    $('[data-behavior~=filterData]').on 'click', =>
      @show_loading_animation()

    # Filtrar recibos al hacer click en botón '$' o en 'RECIBOS'
    $('[data-behavior~=filter]').on 'click', @filter_receipts


  init_tablesorter: ->
    return if $('#js-noData').length == 1
    $table = $('.tablesorter').tablesorter
      theme : "materialize",
      widthFixed: true,
      widgets : ["filter", "zebra"]

  animate_loading: ->
    $('[data-behavior~=retry]').remove()
    $('#js-errorBox').removeClass('bg-red').addClass('bg-green')
    $('#js-errorTitle').addClass 'hidden'
    $('#js-loadingState').removeClass 'hidden'
    $('#js-errorBoxText').text('Obteniendo datos...')

  filter_receipts: (e) =>
    currency = $(e.target).data('currency')

    if currency == 'all'
      $('tr.js-receipt').removeClass 'hidden'
      $('.js-currency-col').removeClass 'hidden'
    else
      $('tr.js-receipt').not("[data-currency~=#{currency}]").addClass 'hidden'
      $('.js-currency-col').not(".js-#{currency}-col").addClass 'hidden'
      $("[data-currency~=#{currency}]").removeClass 'hidden'
      $(".js-#{currency}-col").removeClass 'hidden'

  show_loading_animation: ->
    $('.js-dataTable').remove()
    $('.js-loadingData').removeClass('hidden')


$(document).on 'ready turbolinks:load', ->
  if $('.agency_payments.index').length > 0
    $.AdminLTE.boxWidget.activate()
    new AgencyPayments()
