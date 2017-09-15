window.App ||= {}

class App.Alert

  constructor: (@el_id='js-flash') ->
    @bind_events()

  bind_events: ->
    self = @
    $(document).ajaxStart (event, request) ->
      self.startLoading()

    $(document).ajaxComplete (event, request) ->
      self.finishLoading() if $("##{self.el_id}").hasClass 'automaticClose'

      unless request.getResponseHeader("X-Message-Type") is null
        msg = request.getResponseHeader("X-Message")

        alert_type = 'alert-success'
        alert_type = 'alert-danger' unless request.getResponseHeader("X-Message-Type").indexOf("error") is -1
        alert_type = 'alert-danger' unless request.getResponseHeader("X-Message-Type").indexOf("alert") is -1

        unless request.getResponseHeader("X-Message-Type").indexOf("keep") is 0
          self.alert(msg, alert_type)


  alert: (msg, type='alert-info') ->
    if msg
      $("##{@el_id}").replaceWith('<div id="js-flash" class="flash">
        <div class="alert ' + type + '">
          ' + msg + '
        </div>
        ')
      $("##{@el_id}").addClass 'is-active'

  startLoading: (automaticClose=true)->
    if automaticClose
      closeClass = 'automaticClose'
    else
      closeClass = ''

    $("##{@el_id}").replaceWith("<div id='js-flash' class='flash #{closeClass}'>
      <div class='alert alert-info'>
        " + '<div id="fountainG">
              <div id="fountainG_1" class="fountainG"></div>
              <div id="fountainG_2" class="fountainG"></div>
              <div id="fountainG_3" class="fountainG"></div>
             </div>' + '
      </div>
      ')
    $("##{@el_id}").addClass 'is-loading'

  finishLoading: ->
    $("##{@el_id}").removeClass 'is-loading'
    $("##{@el_id}").hide()

# --
root = exports ? this

$(document).on "ready turbolinks:change", ->
  root.flashAlert = new App.Alert()
$(document).on "page:fetch", ->
  flashAlert.startLoading()
$(document).on "page:receive", ->
  flashAlert.finishLoading()
