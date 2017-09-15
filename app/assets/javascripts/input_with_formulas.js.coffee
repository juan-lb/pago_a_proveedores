jQuery.fn.inputWithFormulas = (options) ->

  $(this).attr('autocomplete', 'off')
  $(this).data('previous-val', $(this).val())
  old_value = $(this).val()

  # Paso el input a type text porque con number filtra
  # los caracteres que no son números
  $(this).focus (event)->
    $(this).data('old-type', $(this).attr('type'))
    $(this).attr('type', 'text')


  # Cuando pierde foco vuelvo el type a number
  $(this).blur (event)->
    $(this).attr('type', $(this).data('old-type'))
    $(this).removeClass 'error'

  # Si se presiona Enter calculo la formula
  $(this).keydown (event)->
    element = $(this)

    if event.keyCode == 13 or event.keyCode == 9
      result = element.val()
      if event.keyCode == 13
        if Utilities.isAFormulaString(result) && element.data('previous-val') != result
          event.preventDefault()
          event.stopPropagation()
      try
        result = element.val()
        if Utilities.isAFormulaString(result)
          element.val(eval(result))
        else
          element.val(parseFloat(result))
        element.data('previous-val', result+'')
        element.removeClass 'error'
      catch e
        element.addClass 'error'

      element.focus()
