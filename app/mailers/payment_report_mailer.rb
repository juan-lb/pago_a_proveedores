class PaymentReportMailer < BaseMandrillMailer
  include ActionView::Helpers::TextHelper

  def send_report(report)
    merge_vars = {
      message:   simple_format(report.message),
      msg_title: report.title,
      swift:     simple_format(report.swift),
      sender:    report.sender
    }

    mandrill_template(report.users, Const::MANDRILL_PAYMENT_REPORT, merge_vars, [], report.attachment, report.users.first[:email])

  end

end
