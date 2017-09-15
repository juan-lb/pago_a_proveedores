class TransfersAverageMailer < BaseMandrillMailer
  include ActionView::Helpers::TextHelper

  def send_report(report)
    mandrill_template(report.users, Const::MANDRILL_TRANSFERS_AVERAGE_REPORT, {}, [], report.attachment)
  end

end
