require 'active_support/concern'

module PaymentStatusesModule
  extend ActiveSupport::Concern

  included do
    Const::PAYMENT_STATUSES.each do |key, value|
      define_method("#{key}?") { self.status == value }
    end
  end

end
