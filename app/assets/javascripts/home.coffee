class Home

  constructor: ->
    @bindEvents()

    $('#statusFilter').select2()


  bindEvents: ->
    # Limpiar 'OK para pagar' al clickear 'Borrar'
    $('[data-behavior~=cleanPayable]').on 'click', ->
      $('#payable_list').empty()
      $('#repeated_reserves').empty()

    # Limpiar 'Pagos posibles' al clickear 'Borrar'
    $('[data-behavior~=cleanPossiblePayments]').on 'click', ->
      $('#possible_payments_list').empty()

    # Habilitar filtro por estado en 'Pagos Posibles'
    $('[data-behavior~=enableStatusFilter]').on 'click', =>
      @enableStatusFilter()

  enableStatusFilter: =>
    button  = $('#js-enableStatusFilter')
    wrapper = $('.js-statusFilter')

    button.attr('disabled', true)
    wrapper.removeClass('hidden')


$(document).on 'ready turbolinks:load', ->
  new Home if $('.home').length > 0
