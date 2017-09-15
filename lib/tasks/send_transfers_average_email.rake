namespace :operators_transfer_average_report do
  desc 'Envía un email a los usuarios definidos en Setting con un reporte de transferencias diarias promedio por operador'

  task send_email: :environment do
    today = Date.today

    if today.monday? && today.day <= 7
      TransfersAverageReport.new(ActionView::Base.new).send
    else
      puts 'Reporte de promedio de transferencias no enviado: no es primer lunes de mes.'
    end

  end

end
