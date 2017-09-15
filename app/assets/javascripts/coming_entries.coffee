class App.ComingEntries

  constructor: () ->
    @bindEvents()

  bindEvents: () ->
    $('[data-behavior~=showAmountFilter]').on 'click', ->
      $('#js-comingEntriesAmountInputs').removeClass 'hidden'
      $(this).addClass 'hidden'

$(document).on "ready turbolinks:load", ->
  new App.ComingEntries unless $('#coming_entries').length == 0
