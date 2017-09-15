class PaymentGroups

  constructor: () ->
    @bindEvents()

  bindEvents: ->
    $('.js-payment-group input[type=checkbox], [data-behavior~=select_all_checkboxes]').on 'click', (e)=>
      @onPaymentGroupSelected $(e.target)

    $('[data-behavior~=view_payment]').on 'click', (e) =>
      @markLinkAsSeen(e.target)

    $('[data-behavior~=selectSellers]').select2
      allow_clear: true
      placeholder: 'Seleccione vendedores'
      formatNoMatches: 'No hay resultados'
      minimumResultsForSearch: 20


  onPaymentGroupSelected: (selected) ->
    @calculateSelectedTabSum $(selected.closest('.js-tab'))

  calculateSelectedTabSum: (tab)->
    ars = 0
    usd = 0

    tab.find('.js-payment-group input:checked').each (i, checkbox) ->
      total    = $(checkbox).closest('.js-payment-group').find('.js-total')
      currency = total.data('currency')

      if currency == 'P'
        ars += Utilities.unformatMoney($(total).html())
      else
        usd += Utilities.unformatMoney($(total).html())

    tab.find('.js-selected-ars-sum').html Utilities.formatMoney(ars, 2, '')
    tab.find('.js-selected-usd-sum').html Utilities.formatMoney(usd, 2, '')

  markLinkAsSeen: (link) ->
    $(link).addClass("color-violet bold")
    $(link).blur()


$(document).on "ready turbolinks:load", ->
  if $(".payment_groups.index").length > 0
    new PaymentGroups()
