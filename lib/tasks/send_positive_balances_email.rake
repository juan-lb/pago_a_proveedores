namespace :operators_positive_balances_report do
  desc 'Envía un email a los usuarios definidos en Setting con un reporte de saldos a favor por operador'

  task send_email: :environment do
    today = Date.today

    if today.monday? && today.day <= 7
      PositiveBalancesReport.new(
        {operators_positive_balances_filter: nil},
        ActionView::Base.new
      ).send
    else
      puts 'Reporte de saldos a favor no enviado: no es primer lunes de mes.'
    end

  end

end
