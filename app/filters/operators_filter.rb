class OperatorsFilter
  include ActiveModel::Model

  attr_accessor :name, :category

  def initialize(*args)
    super
  end

  def call
    operators = Operator.not_guardias.includes(:information)

    operators = operators.search(name) if name.present?

    if category == 'national'
      operators.national
    elsif category == 'international'
      operators.international
    else
      operators
    end
  end

end
