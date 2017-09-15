class OperatorsTransferAverage

  attr_reader :operators, :days

  def initialize
    setting = Setting.take

    @days      = setting.operators_average_days
    @usd_limit = setting.transfer_average_usd_limit
  end

  def international_transfers
    @international_transfers ||= transfers.
      select  { |operator| operator[:category] == 2 }.
      sort_by { |operator| operator[:average] }.
      reverse
  end

  def national_ars_transfers
    @national_ars_transfers ||= transfers.
      select  { |operator| operator[:category] == 1 && operator[:currency] == 'P' }.
      sort_by { |operator| operator[:average] }.
      reverse
  end

  def national_usd_transfers
    @national_usd_transfers ||= transfers.
      select  { |operator| operator[:category] == 1 && operator[:currency] == 'D' }.
      sort_by { |operator| operator[:average] }.
      reverse
  end

  def international_small_transfers
    @international_small_transfers ||= international_transfers.
      select { |operator| operator[:average] < @usd_limit }
  end

  def totals
    {
      international: average(international_transfers),
      national_ars:  average(national_ars_transfers),
      national_usd:  average(national_usd_transfers)
    }
  end

  private

  def transfers
    return @transfers if @transfers

    @transfers = ActiveRecord::Base.connection.exec_query(
      "SELECT \
         O.aptour_id, \
         O.name, \
         SUM(P.total_in_cents / 10000) as total, \
         P.category, \
         currency, \
         COUNT(P.id) as count, \
         GROUP_CONCAT(DISTINCT A.name) as accounts \
       FROM payment_groups P \
       INNER JOIN operators O ON O.aptour_id = operator_aptour_id \
       LEFT JOIN payments p ON p.payment_group_id = P.id \
       LEFT JOIN accounts A ON account_api_id = p.payment_method \
       WHERE P.status = 'Cargado' AND sent_date > '2017-07-02' \
       GROUP BY O.aptour_id, O.name, category, currency"
    )

    @transfers = @transfers.rows.map do |row|
      total = row[2].to_f

      {
        aptour_id: row[0],
        name:      row[1],
        total:     total,
        category:  row[3],
        currency:  row[4],
        count:     row[5],
        average:   total / row[5],
        accounts:  row[6].nil? ? '-' : row[6].split(',').map(&:strip)
      }
    end
  end

  def average(records)
    total = 0
    count = 0

    records.each do |operator|
      total += operator[:total]
      count += operator[:count]
    end

    return 0.0 if count.zero?

    (total / count).round 2
  end

end
