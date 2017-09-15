module InputHelper

  def datepicker_input(form, attribute, html_options = {})
    append_input(form, attribute, :calendar, :datepicker, html_options)
  end

  def timepicker_input(form, attribute, html_options = {})
    html_options[:wrapper] = :append
    form.input attribute, html_options do
      concat form.input_field(attribute, class: 'form-control timepicker-input')
      concat content_tag(:span, icon('clock-o'), class: 'input-group-addon')
    end
  end

  def append_input(form, attribute, icon_name, wrapper = :append, html_options = {})
    html_options[:wrapper] = wrapper
    form.input attribute, html_options do
      concat form.input_field(attribute, as: :string, class: html_options[:class])
      concat content_tag :span, (form.label attribute, icon(icon_name)), id: "#{form.object.class}-#{attribute}", class: 'input-group-addon'
    end
  end

end
