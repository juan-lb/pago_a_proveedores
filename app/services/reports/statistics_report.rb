class StatisticsReport
  include ActiveModel::Model

  attr_accessor :user, :to, :attachment, :message

  def initialize(attrs=nil, filter_params=nil, view_context=nil)
    super attrs
    set_attachment filter_params, view_context
  end

  def send
    StatisticsReportMailer.send_report(self).deliver_now!
  end

  def user
    @user ||= {name: 'Usuario PaP', email: to}
  end

  private

  def set_attachment(filter_params, view_context)
    return nil if view_context.nil?

    pdf = StatisticsReportPdf.new(
      {statistics_filter: filter_params},
      view_context
    ).render

    @attachment = {
      type:     'application/pdf',
      name:     'estadisticas_de_pagos.pdf',
      content:  Base64.encode64(pdf)
    }
  end

end
