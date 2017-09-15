class StatisticsController < ApplicationController

  def index
    @presenter = StatisticsPresenter.new(
      params: params,
      current_user: current_user
    )
  end

  def export
    pdf = StatisticsReportPdf.new(
      {statistics_filter: params[:filter_params]},
      view_context
    )

    respond_to do |format|
      format.pdf { send_data pdf.render, export_options(params) }
    end
  end

  def export_excel
    @presenter = StatisticsPresenter.new(params: params)
    @view      = view_context

    respond_to do |format|
      format.xlsx {
        render xlsx: "export_to_xlsx",
          locals: {
            xlsx_use_shared_strings: true
        }
      }
    end
  end

  def report_form; end

  def send_report
    StatisticsReport.new(
      report_params, params[:filter_params],
      view_context
    ).send

    flash[:success] = 'Se ha enviado el correo correctamente'
  end

  private

  def report_params
    params.require(:statistics_report) .permit(:to, :message)
  end

  def export_options(params)
    options = {
      filename: "estadisticas_de_pagos.pdf",
      type:     "application/pdf"
    }

    options.merge!(
      {disposition: 'inline'}
    ) if params[:inline] == 'true'

    options
  end

end
