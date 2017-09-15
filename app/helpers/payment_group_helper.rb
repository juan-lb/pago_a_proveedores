module PaymentGroupHelper

  def payment_group_category(record)
    record.category == 1 ? 'Nacional' : 'Internacional'
  end

end
