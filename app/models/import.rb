# == Schema Information
#
# Table name: imports
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  wrong_reserves     :text(65535)
#  gateway            :integer          default(0)
#  operator_aptour_id :integer          default(-1)
#

class Import < ActiveRecord::Base

  # -- Associations
  belongs_to :operator,
    primary_key: 'aptour_id',
    foreign_key: 'operator_aptour_id'

  # -- Custom attributes
  serialize :wrong_reserves
  enum gateway: {auto: 0, manual: 1}

  # -- Misc
  ALL_OPERATORS = -1
  ATTEMPTS      = 5

  # -- Methods
  def operator
    return nil unless operator_aptour_id.positive?

    Operator.find_by(aptour_id: operator_aptour_id)
  end

  def self.load(gateway: :auto, operator_id: ALL_OPERATORS)
    operator_to_import = operator_id == ALL_OPERATORS ? 0 : operator_id

    Setting.start_importation

    OperatorImportation.new.call
    ProviderImportation.new.call

    registers   = ServiceRegisterImporter.new.call operator_to_import
    importation = Importation.new(registers).call  gateway, operator_id

    Setting.stop_importation

    importation

  rescue Exception => e
    Setting.stop_importation
    Rails.logger.error "Falló la importación. Error message: #{e}"
  end

  def self.remote_import
    ATTEMPTS.times do
      begin
        break if self.load
      rescue Exception => e
        puts e.message
        puts e.backtrace
      end
    end
  end

end
