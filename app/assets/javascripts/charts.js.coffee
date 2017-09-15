# $(".application.home").ready ->
#
#     startDate = String($('.js-startDate').val())
#     endDate = String($('.js-endDate').val())
#     fecType = $('.js-fec_type:checked').val()
#
#     #Gráfico de próximos vencimientos en pesos
#     results = $.ajax(
#       url: '/operators_with_totals.json'
#       dataType: 'json'
#       data:
#           currency: 'P'
#           register_filter:
#               fec_type: fecType
#               from: startDate
#               to: endDate
#       success: (data) ->
#         new (Morris.Donut)(
#           element: 'operators_chart_pesos'
#           data: data)
#         )
#
#     # Gráfico de próximos vencimientos en dólares
#     results = $.ajax(
#       url: '/operators_with_totals.json'
#       dataType: 'json'
#       data:
#           currency: 'D'
#           register_filter:
#               fec_type: fecType
#               from: startDate
#               to: endDate
#       success: (data) ->
#         new (Morris.Donut)(
#           element: 'operators_chart_dollars'
#           data: data)
#         )