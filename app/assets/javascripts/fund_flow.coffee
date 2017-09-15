class FundFlow

  constructor: ->
    @form = $('#js-operator-form')
    @bindEvents()

  bindEvents: ->
    $('[data-behavior~=selectOperator]').on 'change', ->
      $(@form).trigger('submit.rails')


$(document).on 'ready turbolinks:load', ->
  if $('.fund_flow.index').length > 0
    $.AdminLTE.boxWidget.activate()
    new FundFlow()
