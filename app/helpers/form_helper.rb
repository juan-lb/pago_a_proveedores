module FormHelper

  def custom_form_for(object, *args, &block)
    options = args.extract_options!
    options[:wrapper] = :bootstrap
    options[:defaults] = {input_html: {class: 'form-control'}}
    simple_form_for(object, *(args << options), &block)
  end

  def remove_button(form, klass, html_options= {})
    form.input :_destroy, html_options do 
      concat form.hidden_field(:_destroy)
      concat link_to(t(:remove), '#', class: ["btn", "btn-danger", klass])
    end
  end

  def link_to_add_room(form_builder)
    add_fields 'room', builder: form_builder, element_id: 'element'
  end

  def add_fields(name, builder: form_builder, element_id: nil)
    plural     = name.pluralize
    new_object = builder.object.send(plural).klass.new
    id         = new_object.object_id

    fields = builder.simple_fields_for(plural, new_object, child_index: id) do |form_builder|
      render("#{name}_fields", f: form_builder)
    end

    link_to I18n.t(name, scope: :add_link), '#', id: "add-#{element_id || name.dasherize}", data: {id: id, fields: fields.gsub("\n", "").gsub('"', "'")}
  end

end