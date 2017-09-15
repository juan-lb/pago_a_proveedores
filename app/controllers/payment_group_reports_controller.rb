class PaymentGroupReportsController < ApplicationController

  before_action :set_payment_group, only: [:show, :export]
  before_action :set_and_update_payment_group_report, only: [:export]

  def export
    pdf = PaymentGroupReportPdf.new(
      @report,
      @payment_group.difference,
      view_context
    )

    respond_to do |format|
      format.pdf do
        send_data pdf.render,
          filename: "DetallePago_#{@report.payment_group.created_at.strftime("%d-%m-%Y")}.pdf",
          disposition: "inline",
          type: "application/pdf"
      end
    end
  end

  def show
    @report = @payment_group.payment_group_report

    render 'payment_groups/report'
  end

  def update
    @report = PaymentGroupReport.find(params[:id])

    respond_to do |format|
      if @report.update_attributes(payment_group_report_params)
        format.json { respond_with_bip(@report) }
      else
        format.json { respond_with_bip(@report) }
      end
    end
  end

  private

  def set_payment_group
    @payment_group = PaymentGroup.find(params[:id])
  end

  def set_and_update_payment_group_report
    @report = PaymentGroupReport.find_or_create_by(payment_group: @payment_group)
    @report.update_attributes(payment_group_report_params)
  end

  def payment_group_report_params
    params.require(:payment_group_report).permit(:payment_group_id, :note, :swift, :printable_column, :euros_difference)
  end

end
