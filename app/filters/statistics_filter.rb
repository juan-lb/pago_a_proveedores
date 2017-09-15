class StatisticsFilter
  include ActiveModel::Model

  attr_accessor :operator_category, :from, :to, :order_by, :order_as, :from_2, :to_2, :comparison_mode, :selected_to

  ORDER_BY = %w(fecha operador)
  ORDER_AS = %w(ascendente descendente)
  ORDER_HASH = {
    'fecha'       => 'sent_date',
    'operador'    => 'operator_name',
    'ascendente'  => 'ASC',
    'descendente' => 'DESC'
  }

  def initialize(*args)
    super
    @comparison_mode = from_2.present? && to_2.present?
    @selected_to     = set_selected_to
  end

  def call(sort_params=nil)
    records = PaymentGroup.unscoped.
      where(is_credit: false).
      where("status = 'Cargado' OR status = 'Enviado'").
      includes(:services, :operator, :payment => :account).
      select('*')

    records = filter(records)
  end

  private

  def filter(records)
    records = records.where(category: 1) if operator_category.present? && operator_category == 'national'
    records = records.where(category: 2) if operator_category.present? && operator_category == 'international'
    records = date_filter(records)
    records = records.order(order_criteria)
    records
  end

  def order_criteria
    order_by = @order_by.nil? ? "" : ORDER_HASH[@order_by]
    order_as = @order_as.nil? ? "" : ORDER_HASH[@order_as]
    order_by + " " + order_as
  end

  def date_filter(records)
    start  = from.to_datetime.beginning_of_day if from.present?
    finish = selected_to.to_datetime.end_of_day

    records = records.where('sent_date >= ?', start) if start.present?
    records = records.where('sent_date <= ?', finish)
    records
  end

  def set_selected_to
    finish = nil
    finish = to         if to.present?
    finish = to_2       if to_2.present?
    finish = Date.today if finish.nil?
    finish
  end

end
