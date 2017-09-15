class TransfersAverageReport
  require 'base64'

  attr_accessor :users, :attachment

  def initialize(view_context=nil)
    set_attachment view_context
    set_users
  end

  def send
    TransfersAverageMailer.send_report(self).deliver_now!
  end

  private

  def set_attachment(view_context)
    pdf = OperatorsTransferAveragePdf.new(view_context).render

    @attachment = {
      type:     'application/pdf',
      name:     'promedio_transferencias.pdf',
      content:  Base64.encode64(pdf)
    }
  end

  def set_users
    @users = Setting.take.
      operators_average_emails.
      map { |email| {email: email, name: 'Destinatario'} }
  end

end
