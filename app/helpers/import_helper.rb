module ImportHelper

  def gateway_label(import)
    if import.auto?
      klass = 'label label-success'
      title = 'Automática'
    else
      klass = 'label label-primary'
      title = 'Manual'
    end

    content_tag :span, title, class: klass
  end

end
