# == Schema Information
#
# Table name: services
#
#  id                 :integer          not null, primary key
#  reserve_id         :integer
#  agency_id          :integer
#  leg_ope            :string(255)
#  service_number     :integer
#  amount_in_cents    :integer
#  date               :datetime
#  date_out           :datetime
#  viajeroresponsable :string(255)
#  operator_id        :integer
#  payment_group_id   :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  is_valid           :boolean          default(TRUE)
#  euros              :float(24)
#  details            :text(65535)
#  operator_aptour_id :integer
#  currency           :string(255)
#  date_in            :datetime
#  seller_aptour_id   :string(4)
#  provider_aptour_id :integer
#

class Service < ActiveRecord::Base

  # -- Callbacks
  before_destroy :restore_service_register

  # -- Associations
  belongs_to :operator,
    foreign_key: 'operator_aptour_id',
    primary_key: 'aptour_id'
  belongs_to :provider,
    foreign_key: 'provider_aptour_id',
    primary_key: 'aptour_id'
  belongs_to :payment_group
  belongs_to :reserve,
    foreign_key: 'reserve_id',
    primary_key: 'reserve_id'
  belongs_to :seller,
    class_name: 'User',
    foreign_key: 'seller_aptour_id',
    primary_key: 'aptour_id'

  # -- Scopes
  scope :debits, -> { where("amount_in_cents > 0") }
  scope :credits, -> { where("amount_in_cents < 0") }

  # -- Methods
  def self.service_registers(services)
    conditions = services.map { |s| "(operator_aptour_id = #{s.operator_aptour_id} AND id_res = #{s.reserve_id} AND numero = #{s.service_number})" }
    ServiceRegister.where(conditions.join(' OR '))
  end

  def service_register
    ServiceRegister.find_by(
      id_res: reserve_id,
      numero: service_number
    )
  end

  def credit?
    amount < 0
  end

  def debit?
    amount > 0
  end

  def self.attributes_in_cents
    ['amount']
  end

  def currency_type
    return currency unless currency.nil?

    if service_register.nil?
      '-'
    else
      service_register.moneda
    end

  end

  include IntegerInCents

  private

  def restore_service_register
    service_register = ServiceRegister.find_by(
      id_res: self.reserve_id,
      numero: self.service_number,
      marked: true
    )

    service_register.update(
      marked: false
    ) unless service_register.nil?
  end

end
