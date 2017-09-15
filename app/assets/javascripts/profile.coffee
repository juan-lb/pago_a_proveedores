class Profile

  constructor: ->
    $('.select2').select2()

$(document).on 'ready turbolinks:load', ->
  if $('.profiles.new, .profiles.edit').length > 0
    new Profile()
