class FromTo
  
  attr_accessor :payment_group, :account
  
  def initialize(payment_group, account)
    @payment_group = payment_group
    @account = account
  end
  
  def call
    if @account.pesos? && @payment_group.in_pesos?
      'PesoToPeso'
    elsif @account.dollars? && @payment_group.in_pesos?
      'DollarToPeso'
    elsif @account.dollars? && @payment_group.in_dollars?
      'DollarToDollar'
    else
      'PesoToDollar'
    end
  end
  
end