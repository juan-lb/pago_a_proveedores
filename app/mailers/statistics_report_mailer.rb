class StatisticsReportMailer < BaseMandrillMailer
  include ActionView::Helpers::TextHelper

  def send_report(report)
    merge_vars = {
      message: simple_format(report.message)
    }

    mandrill_template([report.user], Const::MANDRILL_STATISTICS_REPORT, merge_vars, [], report.attachment)
  end

end
