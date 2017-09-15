jQuery.fn.tags_select = ->
  this.select2(
    multiple: true
    tags: true
  )

jQuery.fn.multiple_local_select = ->
  this.select2(
    escapeMarkup: (markup) -> markup
    minimumInputLength: 2
  )


jQuery.fn.simple_select = (url, placeholder) ->
  this.select2(
    ajax:
      url: url
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
      processResults: (data, page) -> { results: data }
      cache: true
    escapeMarkup: (markup) -> markup
    minimumInputLength: 2
    placeholder: placeholder
    allowClear: false
  )

jQuery.fn.multiple_select = (url) ->
  this.select2(
    ajax:
      url: url
      dataType: 'json'
      delay: 250
      data: (params) ->
        q: params.term
        page: params.page
      processResults: (data, page) -> { results: data }
      cache: true
    escapeMarkup: (markup) -> markup
    minimumInputLength: 2
  )