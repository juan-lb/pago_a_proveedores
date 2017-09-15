require 'active_support/concern'

module CurrencySymbolModule
  extend ActiveSupport::Concern

  included do
    define_method("currency_symbol") {
      if currency == 'P'
        Const::ARS
      elsif currency == 'D'
        Const::USD
      else
        '-'
      end
    }
    define_method("in_pesos?") { currency == 'P' }
    define_method("in_dollars?") { currency == 'D' }
  end

end
