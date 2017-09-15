class OperatorsPayments

  attr_accessor :payments, :ars_total, :usd_total

  def initialize(reserve_id)
    get_payments reserve_id
    get_ars_total
    get_usd_total
  end

  def operator_payment(operator_aptour_id)
    @operator_payment ||= payments.select do |each|
      each[:operator_aptour_id] == operator_aptour_id
    end.first
  end

  private

  def get_payments(reserve_id)
    con = Connection.new(ENV['APTOUR_URL'])
    res = con.get_paid_to_operators(reserve_id)

    @payments =
      if res.status == 200
        process_results res.body
      else
        []
      end
  end

  def process_results(data)
    data.map do |each|
      {
        operator_name:      each['NOM_OPE'].strip,
        operator_aptour_id: each['ID_OPE'],
        ars_paid:           each['PAGOS'].to_f,
        usd_paid:           each['PAGOSUS'].to_f,
        ars_balance:        each['SALDO'].to_f,
        usd_balance:        each['SALDOUS'].to_f
      }
    end
  end

  def get_ars_total
    @ars_total =
      if payments.any?
        payments.inject(0) { |sum, each| sum + each[:ars_paid] }
      else
        0
      end
  end

  def get_usd_total
    @usd_total =
      if payments.any?
        payments.inject(0) { |sum, each| sum + each[:usd_paid] }
      else
        0
      end
  end

end
