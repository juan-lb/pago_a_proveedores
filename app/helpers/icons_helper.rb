module IconsHelper

  def icon(name, html_options={})
    html_options[:class] = ['fa', "fa-#{name}", html_options[:class]].compact
    content_tag(:i, nil, html_options)
  end

  def icon_none
    icon(:none, class: 'fa-fw')
  end

  def action_icon(action_name, klass=nil)
    content_tag :span, '', class: ['action-icon', 'colored', action_name, klass]
  end

  def service_icon(data_type, klass=nil)
    content_tag :span, '', class: ['service-icon', data_type, klass].compact
  end

  def reserve_icon(state)
    content_tag :span, '', class: ['reserve-icon', state], title: I18n.t(state)
  end

  def service_icons(services)
    capture do
      services.each do |service|
        concat colored_service_icon(service) if service.actions.any?
      end
    end
  end

  def colored_service_icon(service)
    state = service.state
    title = [service.name, I18n.t(state, scope: :service_states)].join("\n")
    content_tag :span, '', title: title, class: ['colored-service-icon', 'service-icon', service.data_type, state].compact
  end

  def check_icon(checked, html_options={})
    name = checked ? 'check-square-o' : 'square-o'
    icon name, html_options
  end

end