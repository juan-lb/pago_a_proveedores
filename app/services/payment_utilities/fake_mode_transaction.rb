class FakeModeTransaction

  def initialize(payment_group, options)
    @payment_group     = payment_group
    @account           = options[:account]
    @services          = options[:register_ids]
    @principal_reserve = options[:principal_reserve]
  end

  def call
    if @account.present?
      @payment_group.is_refund? ? impact_expenditure : impact_income
    elsif @services.present?
      @payment_group.is_refund? ? impact_payment : impact_devolution
    end
  end

  private

  def impact_expenditure
    EntryLoader.new(@payment_group).call @account, :expenditure
  end

  def impact_income
    EntryLoader.new(@payment_group).call @account, :income
  end

  def impact_payment
    FakePaymentGroupManager.new(
      @services,
      @principal_reserve,
      @payment_group
    ).call
  end

  def impact_devolution
    FakeRefundManager.new(
      @services,
      @principal_reserve,
      @payment_group
    ).call
  end

end
