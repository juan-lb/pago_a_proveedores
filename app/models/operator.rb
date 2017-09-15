# == Schema Information
#
# Table name: operators
#
#  id                  :integer          not null, primary key
#  name                :string(255)
#  aptour_id           :integer
#  category            :integer
#  has_current_account :boolean          default(FALSE)
#  has_ig_retention    :boolean          default(FALSE)
#  detail              :text(65535)
#  address             :string(255)
#  cuit                :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  business_name       :string(255)
#  bank_accounts       :text(65535)
#

class Operator < ActiveRecord::Base

  # -- Associations
  has_many :service_registers,
    foreign_key: 'operator_aptour_id',
    primary_key: 'aptour_id'

  has_many :payment_groups,
    foreign_key: 'operator_aptour_id',
    primary_key: 'aptour_id'

  has_one :information,
    primary_key: 'aptour_id',
    foreign_key: 'operator_aptour_id',
    class_name:  'OperatorInformation'

  # -- Validations
  validates :aptour_id, presence: true
  validates :name, presence: true
  validates :category, presence: true

  # -- Misc
  enum category: {national: 1, international: 2, undefined: 3}

  # -- Custom attributes
  serialize :bank_accounts, Array

  # -- Scopes
  scope :search, -> (query) { where("name LIKE '%#{query}%'") }
  scope :not_guardias, -> { where.not("name LIKE 'GUARDIA%'") }

  # -- Methods
  def self.all_by_hashes(name)
    Operator.
      where('name LIKE ?', "%#{name}%").
      map { |op| {id: op.aptour_id, text: op.name} }
  end

end
