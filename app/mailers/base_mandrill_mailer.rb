class BaseMandrillMailer < ActionMailer::Base

  private

  def mandrill_client
    @mandrill_client ||= Mandrill::API.new MANDRILL_API_KEY
  end

  # to_email:         viene en la forma { email:mail, name: nombre } o array [{}]
  # template_name:    nombre del template
  # attributes:       parámetros para el template
  # template_content: contenido
  # attachment:       archivo adjunto
  # reply_to:         email para agregar como 'Reply-To'
  def mandrill_template(to_email, template_name, attributes, template_content=[], attachment={}, reply_to=nil)
    merge_vars = attributes.
      map { |key, value| {name: key, content: value} }

    message = {
      from_email:        'noreply@aeromailing.com.ar',
      from_name:         'Aero',
      subaccount:        'aero',
      to:                to_email,
      merge_language:    'handlebars',
      global_merge_vars: merge_vars,
      attachments:       [attachment]
    }

    message[:headers] = {"Reply-To" => reply_to} unless reply_to.blank?

    mandrill_client.messages.send_template(
      template_name,
      template_content,
      message
    )
  end

end
