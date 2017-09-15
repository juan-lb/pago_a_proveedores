module ApplicationHelper

  def flash_message(klass, message)
    flash.discard(klass)
    klass = 'danger' if (klass == 'alert' || klass == 'error')
    klass = 'info' if (klass == 'notice')
    klass = 'success' if (klass == 'success')
    content_tag :article, class: "alert alert-#{klass}" do
      concat message
    end
  end

  def flash_messages
    flash.map { |type, message| flash_message(type, message) }.join.html_safe
  end

  def close_button(target = :modal)
    link_to '&times;'.html_safe, '', class: :close, data: {dismiss: target}
  end

  def currency_symbol(currency)
    if currency == 'P'
      Const::ARS
    elsif currency == 'D'
      Const::USD
    else
      '-'
    end
  end

  def opposite_currency_symbol(currency)
    if currency == 'D'
      Const::ARS
    elsif currency == 'P'
      Const::USD
    else
      '-'
    end
  end

  def sortable(column, direction="asc", title=nil, other_params=nil, selected_column=nil, data_options={})
    title ||= column.titleize
    klass = column == selected_column ? 'text-success' : ''
    link_to title, {sort: column, direction: direction, payment_groups_statistics_filter: other_params }, { class: klass, data: data_options }
  end

  def last_months(size=12)
    months = []
    date = Date.today
    size.times do
      label = Date::MONTHNAMES[date.month] + " " + date.year.to_s
      months << { number: date.month, year: date.year }
      date -= 1.month
    end
    months
  end

  def month_name(number)
    case number
      when 1 then 'Enero'
      when 2 then 'Febrero'
      when 3 then 'Marzo'
      when 4 then 'Abril'
      when 5 then 'Mayo'
      when 6 then 'Junio'
      when 7 then 'Julio'
      when 8 then 'Agosto'
      when 9 then 'Septiembre'
      when 10 then 'Octubre'
      when 11 then 'Noviembre'
      when 12 then 'Diciembre'
    end
  end

  def human_boolean(boolean)
    if boolean
      'Si'
    else
      'No'
    end
  end

end
