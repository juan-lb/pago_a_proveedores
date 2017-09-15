# == Schema Information
#
# Table name: payments
#
#  id                       :integer          not null, primary key
#  total_payment_in_cents   :integer
#  principal_reserve_id     :integer
#  payment_group_id         :integer
#  payment_method           :integer
#  payment_method_number    :string(255)
#  status                   :string(255)      default("Listo")
#  in_aptour                :boolean          default(FALSE)
#  payment_date             :date
#  commission_in_cents      :integer          default(0)
#  iva_in_cents             :integer          default(0)
#  iibb_perception_in_cents :integer          default(0)
#  iva_perception_in_cents  :integer          default(0)
#  cotization_in_cents      :integer
#  total_debt_in_cents      :integer
#  id_mov_in_aptour         :string(255)
#  ig_retention_in_cents    :integer          default(0)
#  eur_cotization_in_cents  :integer
#

class Payment < ActiveRecord::Base

  # -- Associations
  belongs_to :payment_group
  has_many :transfers, dependent: :destroy
  belongs_to :account,
    foreign_key: 'payment_method',
    primary_key: 'account_api_id'

  # -- Validations
  validates :total_debt, presence: true

  # -- Accessors
  attr_accessor :partial_payment, :commission_total, :bank_account

  PAYMENT_METHOD = %w(Cheque Efectivo)

  # -- Methods
  def self.attributes_in_cents
    ['total_payment', 'commission', 'iva', 'iibb_perception', 'iva_perception', 'cotization', 'total_debt', 'ig_retention', 'eur_cotization']
  end

  def commission?
    commission != 0
  end

  def iva?
    iva != 0
  end

  def iibb_perception?
    iibb_perception != 0
  end

  def iva_perception?
    iva_perception != 0
  end

  # Devuelve valor único según fecha e índice de pago. Sirve para construir el identificador de la factura de compra (en caso de necesidad)
  def unique_value_for_invoices
    Date.today.strftime("%d%m%y") + id.to_s.last(2)
  end

  include IntegerInCents

end
