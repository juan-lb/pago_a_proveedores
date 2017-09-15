class OperatorsPositiveBalancesFilter
  include ActiveModel::Model

  attr_accessor :category, :name

  def initialize(*args)
    super
  end

  def call
    records = Operator.
      not_guardias.
      includes(:service_registers).
      select('*')

    if category.present?
      records =
        if category == 'national'
          records.where(category: 1)
        else
          records.where(category: 2)
        end
    end

    if name.present?
      records =
        records.where("name LIKE ?", "%#{name}%")
    end

    records
  end

end
