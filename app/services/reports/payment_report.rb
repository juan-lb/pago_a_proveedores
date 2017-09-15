class PaymentReport
  include ActiveModel::Model
  require 'base64'

  attr_accessor :to, :attachment, :message, :users, :title, :sender, :swift

  def initialize(attrs=nil, payment_group=nil, view_context=nil)
    super attrs
    set_attachment payment_group, view_context
    set_title      payment_group
    set_users      payment_group
  end

  def send(report)
    PaymentReportMailer.send_report(self).deliver_now!

    report.update(last_email_date: Time.zone.now)
  end

  private

  def set_users(payment_group)
    return nil if to.nil?

    @users = to.
      tr('[', '').
      tr(']', '').
      tr('\"', '').
      split(',').
      map { |each| {email: each, name: 'Destinatario'} }

    @users.first.merge!({type: 'cc'})

    save_operator_email payment_group, @users.second[:email]
  end

  def set_title(payment_group)
    return nil if payment_group.nil?

    date   = Date.today
    @title = "Pago AERO #{date.day}-#{Const::MONTHS[date.month].first(3)}"
  end

  def set_attachment(payment_group, view_context)
    return nil if payment_group.nil?

    pdf = PaymentGroupReportPdf.new(
      payment_group.payment_group_report,
      get_difference(payment_group),
      view_context
    ).render

    @attachment = {
      type:     'application/pdf',
      name:     'reporte_de_pago.pdf',
      content:  Base64.encode64(pdf)
    }
  end

  def get_difference(payment_group)
    total = payment_group.services.
      reduce(0) { |sum, s| sum + s.amount }

    if payment_group.payment.total_debt - total == 0
      nil
    else
      payment_group.payment.total_debt - total
    end
  end

  def save_operator_email(payment_group, email)
    OperatorInformation.find_or_create_by(
      operator_aptour_id: payment_group.operator_aptour_id,
      email:              email
    )
  end

end
