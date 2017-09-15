class PositiveBalancesReportMailer < BaseMandrillMailer
  include ActionView::Helpers::TextHelper

  def send_report(report)
    mandrill_template(report.users, Const::MANDRILL_POSITIVES_BALANCES_REPORT, {}, [], report.attachment)
  end

end
