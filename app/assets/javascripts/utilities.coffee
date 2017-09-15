window.Utilities ||= {}

Utilities.formatMoney = (number, places=2, symbol='$')->
  symbol + Utilities.formatNumber(number, places)

Utilities.unformatMoney = (str)->
  price = str.replace(/[^0-9-,]/g, '')
  price = price.replace(',','.')
  parseFloat(price)

Utilities.formatNumber = (number, places=2, thousand='.', decimal=',')->
  places = if !isNaN(places = Math.abs(places)) then places else 2
  negative = if number < 0 then '-' else ''
  i = parseInt(number = Math.abs(+number or 0).toFixed(places), 10) + ''
  j = if (j = i.length) > 3 then j % 3 else 0
  negative + (if j then i.substr(0, j) + thousand else '') + i.substr(j).replace(/(\d{3})(?=\d)/g, '$1' + thousand) + (if places then decimal + Math.abs(number - i).toFixed(places).slice(2) else '')

Utilities.isAFormula = (text) ->
  text.match /\S[+-\/*]+\S/

Utilities.isAFormulaString = (text) ->
  text.includes("+") || text.includes("-") || text.includes("*") || text.includes("/")
