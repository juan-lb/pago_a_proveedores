# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  profile_id :integer
#

class Permission < ActiveRecord::Base

  CONTROLLERS = [
    'imports',
    'operators',
    'operator_informations',
    'reserves',
    'service_registers',
    'services',
    'payment_groups',
    'international_payment_groups',
    'national_payment_groups',
    'refund_payment_groups',
    'statistics',
    'fund_flow',
    'agency_payments',
    'settings',
    'accounts'
  ]

  # -- Associations
  belongs_to :profile

  # -- Validations
  validates :key, presence: true
  validates :key, inclusion: {
    in:      CONTROLLERS,
    message: 'no es una clave válida'
  }
  validates :key, uniqueness: {scope: :profile_id}
  validates :profile, presence: true

end
