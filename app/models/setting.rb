# == Schema Information
#
# Table name: settings
#
#  id                       :integer          not null, primary key
#  ig_limit_in_cents        :integer
#  ig_aliquot               :float(24)
#  ig_base_in_cents         :integer
#  importation_running      :boolean          default(FALSE)
#  max_ars_credit_dif       :float(24)        default(-25.0)
#  max_usd_credit_dif       :float(24)        default(-2.5)
#  operators_average_days   :integer          default(15)
#  operators_average_emails :string(255)      default(["\"ariel.corti@aero.tur.ar\""])
#  positive_balances_emails :string(255)      default(["\"ariel.corti@aero.tur.ar\""])
#  min_ars_credit_report    :float(24)        default(500.0)
#  min_usd_credit_report    :float(24)        default(50.0)
#

class Setting < ActiveRecord::Base

  # -- Misc
  serialize :operators_average_emails, Array
  serialize :positive_balances_emails, Array

  # -- Methods
  def self.attributes_in_cents
    ['ig_limit', 'ig_base']
  end

  include IntegerInCents

  def self.is_importation_running?
    first.importation_running?
  end

  def self.start_importation
    first.update(importation_running: true)
  end

  def self.stop_importation
    first.update(importation_running: false)
  end

end
