class ServiceRegistersPresenter

  attr_accessor :params

  def initialize(params:, current_user:, preselected: false)
    @params        = params
    @current_user  = current_user
    @filter        = filter
    @payment_group = payment_group
    @preselected   = preselected
  end

  def debits
    @debits ||= @filter.debits.decorate
  end

  def credits
    @credits ||= @filter.credits.decorate
  end

  def filter
    @filter ||= RegisterFilter.new(filter_params)
  end

  def payment_group
    @payment_group ||= _payment_group
  end

  def preselected
    @preselected || []
  end

  def reserves
    @reserves ||= ServiceRegister.group(:id_res).count(:id_res)
  end

  def reserves_paid
    @reserves_paid ||= _reserves_paid
  end

  private

  def filter_params
    if @params[:register_filter]
      parameters = @params.
        require(:register_filter).permit(
          :operator_id, :from, :to, :status, :order_by, :order_as,
          :status_service, :beeper, :fec_type, :traveller,
          :consider_passengers, :credits_tab, :reserve,
          :register_ids => []
        ).
        merge({operator_category: operator_category}).
        to_h.
        deep_symbolize_keys
    else
      parameters || {operator_category: operator_category}
    end
  end

  def _payment_group
    PaymentGroup.find_by(
      operator_aptour_id: @filter.operator_id,
      status: Const::PAYMENT_STATUS_DRAFT
    ) if @filter.operator_id.present?
  end

  def operator_category
    @current_user.operator_category
  end

  def _reserves_paid
    ids = []
    ids += debits.map  { |each| each.id_res }
    ids += credits.map { |each| each.id_res }

    con = Connection.new(ENV['APTOUR_URL'])
    res = con.get_multiple_paid_to_operators(ids)

    paid =
      if res.status == 200
        res.body.reduce({}) do |sum, each|
          sum.merge(each['file_number'] => each)
        end
      else
        {}
      end

    ids.each do |id|
      paid[id] = {
        'ars' => 0.0,
        'usd' => 0.0
      } if paid[id].nil?
    end

    paid
  end

end
