module ServiceRegisterHelper

  def details_text(service_register)
    details = service_register.DET_PREV
    icon = ''

    icon = content_tag(:i, nil,
            class: 'fa fa-exclamation-circle text-danger',
            title: 'Existen pagos anticipados',
            style: 'margin-right: 0.5em;'
           ) if service_register.prepaid?

    text = content_tag :span, truncate(details, length: 20),
      title: details,
      data: {
        toggle: 'tooltip',
        placement: 'left',
        container: 'body'
      }

    (icon + text).html_safe
  end

end
