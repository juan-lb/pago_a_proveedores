require 'active_support/concern'

module IntegerInCents
  extend ActiveSupport::Concern

  included do
    attributes_in_cents.each do |name|
      define_method(name.to_sym) { self["#{name}_in_cents"].to_d / 10_000 if self["#{name}_in_cents"]}
      define_method("#{name}=".to_sym) {|args| self["#{name}_in_cents"] = args.to_d * 10_000 if args.present?}
    end
  end

end
