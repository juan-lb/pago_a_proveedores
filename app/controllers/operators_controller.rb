class OperatorsController < ApplicationController

  def all
    render json: Operator.all_by_hashes(params[:q])
  end

  def index
    @presenter = OperatorsPresenter.new(params: params)
  end

  def positive_balances
    @presenter = OperatorsPositiveBalancesPresenter.new(params: params)
  end

  def export_positive_balances
    pdf = OperatorsPositiveBalancesPdf.new(
      {operators_positive_balances_filter: params[:filter_params]},
      view_context
    )

    respond_to do |format|
      format.pdf { send_data pdf.render, {
          filename: "saldos_a_favor.pdf",
          type:     "application/pdf"
        }
      }
    end
  end

  def export_transfers_average
    pdf = OperatorsTransferAveragePdf.new(view_context)

    respond_to do |format|
      format.pdf { send_data pdf.render, {
          filename: "promedio_transferencias.pdf",
          type:     "application/pdf"
        }
      }
    end
  end

end
