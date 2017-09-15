window.App ||= {}

datepicker_configuration =
  changeMonth: true
  changeYear:  true
  yearRange:  '-110:+20'
  dateFormat: 'dd/mm/yy'
  buttonImageOnly: true
  defaultDate: +7

class App.AjaxTabManager
  constructor: (@element = element) ->
    @fetch_only_once = @element.data('fetch-only-once') || false
    @navTabs = @element.closest('.nav-tabs')
    @loaded = false
    @targetTab = $(@element.data('target-tab'))
    @tabContent = @targetTab.closest('.tab-content')
    @bindEvents()

  bindEvents: ->
    @element.click (e)=>
      e.preventDefault()
      @fetch()

  fetch: ->
    if @fetch_only_once && @loaded
      @activateTab()
      return
    $.ajax
      url: @element.attr('href')
    .done (data)=>
      @loaded = true
      @activateTab(data)
      @targetTab.html data
      @loadCoffeesctipts()

  activateTab: ->
    @navTabs.find('li.active').removeClass('active')
    @tabContent.find('.tab-pane.active').removeClass('active')
    @element.closest('li').addClass('active')
    @targetTab.addClass('active')

  loadCoffeesctipts: ->
    App.service_registers = new App.ServiceRegisters unless $(".service_registers").length == 0
    App.InitializationFunctions.init_check_all_checkbox()


App.init = ->
  App.InitializationFunctions.init_operators_select2()
  App.InitializationFunctions.init_best_in_place()
  App.InitializationFunctions.init_datepicker()
  App.InitializationFunctions.init_check_all_checkbox()
  App.InitializationFunctions.init_full_view_in_panel_filter()
  App.InitializationFunctions.init_ajax_tabs()
  App.InitializationFunctions.init_checkboxes()
  App.InitializationFunctions.init_tooltips()
  App.InitializationFunctions.init_formula_inputs()
  App.InitializationFunctions.init_tablesorter()

  # Reactivo eventos de AdminLTE porque se pierden con turbolinks
  $.AdminLTE.layout.activate()

App.make_sortable_table = (table) =>
  th = table[0].tHead
  i  = undefined
  th and (th = th.rows[0]) and (th = th.cells)

  if th
    i = th.length
  else
    return

  while --i >= 0
    do (i) ->
      dir = 1
      unless $(th[i]).hasClass('sorter-false')
        th[i].addEventListener 'click', ->
          App.sort_table table[0], i, dir = 1 - dir
          return
      return
  return

App.sort_table = (table, col, reverse) ->
  tb      = table.tBodies[0]
  tr      = Array::slice.call(tb.rows, 0)
  i       = undefined
  reverse = -(+reverse or -1)

  tr = tr.sort((a, b) ->
    reverse * a.cells[col].textContent.trim().localeCompare(b.cells[col].textContent.trim())
  )

  i = 0
  while i < tr.length
    tb.appendChild tr[i]
    ++i
  return

App.developer = ->
  modal = $('#modal')
  html  = "<div class='modal-body text-center bold'><h3>Hourquebie, Lucas</h3><h3 class='text-primary'>Snappler SRL</h3></div>"

  modal.find('.modal-content').html html
  modal.modal 'show'

App.InitializationFunctions =
  init_operators_select2: () ->
    $('.operator_select2').simple_select '/operators/all', 'Buscar operador'

  init_best_in_place: () ->
    $(".best_in_place").best_in_place()

  init_datepicker: () ->
    $(".input-group.date input").datepicker("destroy")
    $(".input-group.date input").datepicker(datepicker_configuration)

  init_particular_datepicker: (input) ->
    input.datepicker(datepicker_configuration)

  init_check_all_checkbox: () ->
    $('#checkbox_service_registers_debit, #checkbox_service_registers_credit, #checkbox_services, #checkbox_statistics').on 'change', (elem) ->
      cbxs = $(elem.target).closest('table').find('.checkbox_tag')
      cbxs = $(elem.target).closest('table').find(':checkbox') if cbxs.length == 0
      cbxs.prop 'checked', $(this).prop('checked')

  init_full_view_in_panel_filter: () ->
    $('#js-full_view_btn').on 'click', ->
      if $('#js-panel_service_registers').hasClass("col-md-12")
        $('#js-panel_service_registers').removeClass('col-md-12').addClass('col-md-9')
        $('#js-panel_services').removeClass('hidden').addClass('col-md-3')
      else
        $('#js-panel_service_registers').removeClass('col-md-9').addClass('col-md-12')
        $('#js-panel_services').addClass('hidden')
      $('#js-full_view_btn i').toggleClass('fa-indent fa-outdent')

  init_ajax_tabs: () ->
    $('[data-behavior~=ajax-tab]').each ->
      new App.AjaxTabManager $(@)

  init_checkboxes: ->
    $('[data-behavior~=select_all_checkboxes]').click (e) ->
      parent = $(e.target).data 'checkboxes-parent'
      $(parent).find('input[type=checkbox]').prop('checked', e.target.checked)

  init_tooltips: (parent) ->
    elements = if parent then parent.find("a, span, i, div, td, h5") else $("a, span, i, div, td, h5")
    elements.tooltip()

  init_formula_inputs: ->
    $('.js-formulaInput').inputWithFormulas()

  init_tablesorter: ->
    jQuery.tablesorter.addParser
      id: 'fancyNumber'
      is: (s) ->
        /^[0-9]?[0-9,\.]*$/.test s
      format: (s) ->
        jQuery.tablesorter.formatFloat s.replace(/\./g, '')
      type: 'numeric'

$(document).on "ready turbolinks:load", ->
  App.init()
