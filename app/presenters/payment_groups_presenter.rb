class PaymentGroupsPresenter

  def initialize(params:, current_user:)
    @params         = params
    @user           = current_user
    @filter         = filter
    @payment_groups = filter.call
  end

  def filter
    @filter ||= PaymentGroupFilter.new(
      query: filter_params,
      user:  @user,
      page:  @params[:page]
    )
  end

  def payment_groups(type = :all)
    @payment_groups.send(type).paginate(
      page:     @params[:page],
      per_page: Const::PER_PAGE
    )
  end

  def count(type = :all)
    @payment_groups.send(type).count
  end

  def total_ars(type = :all)
    total_by_type_and_currency(type, 'P')
  end

  def total_usd(type = :all)
    total_by_type_and_currency(type, 'D')
  end

  private

  def total_by_type_and_currency(type, currency)
    records = @payment_groups.
      send(type).
      where(currency: currency).
      page(@params[:page])

    if type == :draft
      records.map(&:total)
    else
      records.map(&:total_to_pay)
    end.inject(0, :+)
  end

  def filter_params
    if @params[:payment_group_filter]
      parameters = @params.require(:payment_group_filter).permit(
        :operator_id,
        :operator_category,
        :status,
        :reserve,
        :leg_ope,
        :from,
        :to,
        :passenger,
        :refund,
        :page,
        sellers: []
      )
    end
  end

end
