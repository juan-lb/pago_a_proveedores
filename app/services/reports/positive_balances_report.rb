class PositiveBalancesReport

  attr_accessor :users, :attachment

  def initialize(filter_params=nil, view_context=nil)
    set_attachment filter_params, view_context
    set_users
  end

  def send
    PositiveBalancesReportMailer.send_report(self).deliver_now!
  end

  private

  def set_attachment(filter_params, view_context)
    return nil if view_context.nil?

    pdf = OperatorsPositiveBalancesPdf.new(
      {operators_positive_balances_filter: filter_params},
      view_context
    ).render

    @attachment = {
      type:     'application/pdf',
      name:     'saldos_a_favor.pdf',
      content:  Base64.encode64(pdf)
    }
  end

  def set_users
    @users = Setting.take.
      positive_balances_emails.
      map { |email| {email: email, name: 'Destinatario'} }
  end

end
