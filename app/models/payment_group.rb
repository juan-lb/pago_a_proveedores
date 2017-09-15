# == Schema Information
#
# Table name: payment_groups
#
#  id                 :integer          not null, primary key
#  status             :string(255)
#  profile_id         :integer
#  operator_id        :integer
#  total_in_cents     :integer          default(0)
#  currency           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  category           :integer
#  operator_name      :string(255)
#  is_credit          :boolean          default(FALSE)
#  type               :string(255)      not null
#  operator_aptour_id :integer
#  in_euros           :boolean          default(FALSE)
#  sent_date          :datetime
#  payment_group_id   :integer
#  adjustment         :boolean          default(FALSE)
#

class PaymentGroup < ActiveRecord::Base

  attr_accessor :cotization

  # -- Callbacks
  before_destroy :check_status

  # -- Associations
  belongs_to :profile
  has_many :services, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_one :payment_group_report, dependent: :destroy
  belongs_to :operator,
    foreign_key: 'operator_aptour_id',
    primary_key: 'aptour_id'
  belongs_to :payment_group

  # -- Scopes
  default_scope { order("created_at DESC") }
  scope :from_national_operator, -> { joins(:operator).where('operators.category = 1') }
  scope :from_international_operator, -> { joins(:operator).where('operators.category = 2') }
  scope :draft, -> { where(status: Const::PAYMENT_STATUS_DRAFT) }
  scope :in_process, -> { where(status: Const::PAYMENT_STATUS_IN_PROCESS) }
  scope :sent, -> { where(status: Const::PAYMENT_STATUS_SENT) }
  scope :closed, -> { where(status: Const::PAYMENT_STATUS_CLOSED) }

  TYPES = %w(National International)

  # -- Methods
  def self.attributes_in_cents
    ['total']
  end

  include IntegerInCents
  include PaymentStatusesModule
  include CurrencySymbolModule

  def change_status(binary_boolean)
    conn = Connection.new(ENV["APTOUR_URL"])

    services.map do |serv|
      # Marca el servicio de una reserva como enviado,
      # a la espera de que el banco acepte/rechace la transacción
      conn.change_status(
        serv.reserve_id,
        serv.service_number,
        binary_boolean
      ) if serv.amount > 0
    end
  end

  def self.without_bank_charges
    PaymentGroup.closed.
      where(is_credit: false, category: 2).
      includes(:payment).
      select do |each|
        each.payment.commission == 0
      end
  end

  def empty?
    services.empty?
  end

  def is_valid?
    services.map(&:is_valid).all?
  end

  def retention_amount
    payment.present? ? payment.ig_retention : 0
  end

  def debts_amount
    services.map(&:amount).select { |amount| amount > 0 }.inject(0, :+)
  end

  def credits_amount
    services.map(&:amount).select { |amount| amount < 0 }.inject(0, :+)
  end

  def has_difference?
    difference > 0
  end

  def difference
    total = services.reduce(0) { |sum, s| sum + s.amount }
    (sent? || closed?) ? (payment.total_debt - total) : 0
  end

  def is_credit?
    is_credit
  end

  def is_debit?
    !is_credit
  end

  def is_refund?
    type == 'RefundPaymentGroup'
  end

  def credit_with_no_debits?
    is_credit? && services.debits.empty?
  end

  def has_euros?
    services.any? { |s| s.euros.present? && s.euros > 0 }
  end

  def total_euros
    services.map { |s| s.euros || 0 }.sum
  end

  def national?
    return type == 'NationalPaymentGroup' if operator.nil?

    operator.national?
  end

  def international?
    return type == 'InternationalPaymentGroup' if operator.nil?

    operator.international?
  end

  def total_to_pay
    return total if is_credit?

    total + difference - retention_amount
  end

  def currency_for_statistics
    return 'E' if eur_payment_with_usd_bills? || in_euros

    if self.international?
      'D'
    else
      currency
    end

  end

  def currency_symbol_for_statistics
    if in_euros || eur_payment_with_usd_bills?
      'EUR'
    else
      currency_symbol
    end
  end

  def total_for_statistics
    if in_euros
      amount = total_euros.round 2
    else
      amount = is_credit? ? total : (total + difference - retention_amount)
      amount *= (payment.cotization / payment.eur_cotization) if eur_payment_with_usd_bills?
    end

    amount
  end

  def has_associated_payment_group?
    payment_group.present?
  end

  private

  def check_status
    if closed?
      errors[:base] << "No se puede eliminar un pago que ya fue impactado en Aptour"
      return false
    end

    update_associated_payment_group if payment_group.present?

    true
  end

  def update_associated_payment_group
    if adjustment
      ActiveRecord::Base.transaction do
        amount = 0

        payment_group.services.each do |service|
          service.update amount: service.service_register.service_dif
          amount += service.amount
        end

        payment_group.update(
          payment_group_id: nil,
          total:            amount
        )
      end
    else
      payment_group.destroy
    end
  end

  def eur_payment_with_usd_bills?
    # Consulta si el operador de los pagos es CUBATUR, IBEROSTAR CUBA o SOLWAYS CUBA
    operator_aptour_id.in?([813, 1516, 1212]) &&
      !payment.eur_cotization.nil?
  end

end
