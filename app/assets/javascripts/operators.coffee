class Operators

  constructor: () ->
    # Ocultar operadores sin créditos al hacer click en botón
    $('[data-behavior~=hideOperators]').on 'click', @hide_null_credit_operators

    # Ocultar operadores al hacer click en 'Importar'
    $('[data-behavior~=import]').on 'click', @hide_operators


  hide_null_credit_operators: (e) =>
    btn = $(e.target)
    btn.attr 'disabled', true
    $('[data-has_credit~=false]').addClass 'hidden'

  hide_operators: =>
    $('#js-operators').empty()
    $('.js-loadingStatistics').removeClass('hidden')


$(document).on 'ready turbolinks:load', ->
  if $('.operators').length > 0
    $.AdminLTE.boxWidget.activate()
    new Operators()
