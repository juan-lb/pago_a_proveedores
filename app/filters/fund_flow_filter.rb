class FundFlowFilter
  include ActiveModel::Model

  attr_accessor :from, :to, :operator_category, :operator_cc, :operator_aptour_id

  OPERATOR_CC = {
    'Todos'                => :all,
    'Con cuenta corriente' => :with_cc,
    'Sin cuenta corriente' => :without_cc
  }

  DATE_QUERY  = "(fec_pag IS NOT NULL AND fec_pag >= ? AND fec_pag <= ?) OR (fec_pag IS NULL AND fec_sal >= ? AND fec_sal <= ?)"

  def initialize(*args)
    super
    @from = from.present? ? from.to_date : Date.today
    @to   = to.present? ? to.to_date : Date.today + 14.days
  end

  def call(all_operators)
    records = ServiceRegister.
      not_marked.
      with_debt.
      where(DATE_QUERY, from, to, from, to)

    filter_records(records, all_operators)
  end

  def operators
    if operator_aptour_id.nil?
      {}
    else
      [[
        Operator.find_by(aptour_id: operator_aptour_id).name,
        operator_aptour_id
      ]]
    end
  end

  def selected_operator
    operator_aptour_id.nil? ? {} : {selected: operator_aptour_id}
  end

  private

  def filter_records(records, all_operators)
    if operator_category.present?
      records =
        if operator_category == 'national'
          records.from_national_operator
        else
          records.from_international_operator
        end
    end

    if operator_cc
      records =
        case operator_cc.to_sym
        when :with_cc
          records.ope_with_cc
        when :without_cc
          records.ope_without_cc
        else
          records
        end
    end

    if operator_aptour_id.present? && !all_operators
      records = records.from_operator(operator_aptour_id)
    end

    records
  end

end
