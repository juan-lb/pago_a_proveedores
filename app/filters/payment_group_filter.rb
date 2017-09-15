class PaymentGroupFilter
  include ActiveModel::Model

  attr_accessor :operator_id, :status, :operator_category, :from, :to, :reserve, :leg_ope, :passenger, :sellers, :refund, :page

  def initialize(query:, user:, page:)
    if query
      @operator_category = query[:operator_category]
      @status            = query[:status]
      @operator_id       = query[:operator_id]
      @from              = query[:from]
      @to                = query[:to]
      @reserve           = query[:reserve]
      @leg_ope           = query[:leg_ope]
      @passenger         = query[:passenger]
      @sellers           = query[:sellers]
      @refund            = query[:refund].present?
      @page              = page.blank? ? 1 : page.to_i
    else
      @status            = Const::PAYMENT_STATUS_CLOSED
      @operator_category = user.operator_category
      @page              = 1
    end
  end

  def call
    payment_groups = PaymentGroup.
      unscoped.
      order('payment_groups.created_at DESC')

    payment_groups =
      if refund
        payment_groups.where(type: 'RefundPaymentGroup')
      else
        payment_groups.where.not(type: 'RefundPaymentGroup')
      end

    payment_groups = from_operator? payment_groups
    payment_groups = between_dates? payment_groups

    if filter_params?
      payment_groups = payment_groups.joins(:services)
      payment_groups = with_reserve?   payment_groups
      payment_groups = with_sellers?   payment_groups
      payment_groups = with_leg_ope?   payment_groups
      payment_groups = with_passenger? payment_groups
    end

    payment_groups = payment_groups.includes(
      :services,
      :payment
    ) if payment_groups.any?

    Struct.new(:draft, :in_process, :sent, :closed).new(
      payment_groups.draft,
      payment_groups.in_process,
      payment_groups.sent,
      payment_groups.closed.page(page)
    )
  end

  private

  def from_operator?(payment_groups)
    if operator_category.present?
      payment_groups =
        if operator_category == 'national'
          payment_groups.where(category: 1)
        elsif operator_category == 'international'
          payment_groups.where(category: 2)
        end
    end

    if operator_id.present?
      payment_groups = payment_groups.where(
        operator_aptour_id: operator_id
      )
    end

    payment_groups
  end

  def between_dates?(payment_groups)
    if from.present?
      payment_groups = payment_groups.where(
        'payment_groups.updated_at >= ?',
        from.to_datetime.beginning_of_day
      )
    end

    if to.present?
      payment_groups = payment_groups.where(
        'payment_groups.updated_at <= ?',
        to.to_datetime.end_of_day
      )
    end

    payment_groups
  end

  def filter_params?
    reserve.present? || leg_ope.present? || passenger.present? || sellers.present?
  end

  def with_reserve?(payment_groups)
    return payment_groups unless reserve.present?

    payment_groups.
      where('reserve_id = ?', "#{reserve}").
      distinct
  end

  def with_sellers?(payment_groups)
    return payment_groups unless sellers.present?

    payment_groups.
      joins(:services).
      where('services.seller_aptour_id' => sellers).
      references(:services)
  end

  def with_leg_ope?(payment_groups)
    return payment_groups unless leg_ope.present?

    payment_groups.
      where('leg_ope LIKE ?', "%#{leg_ope}%").
      distinct
  end

  def with_passenger?(payment_groups)
    return payment_groups unless passenger.present?

    payment_groups.
      where('viajeroresponsable LIKE ?', "%#{passenger}%").
      distinct
  end

end
