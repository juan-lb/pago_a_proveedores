# == Schema Information
#
# Table name: service_registers
#
#  id                      :integer          not null, primary key
#  id_usu                  :string(255)
#  id_ope                  :integer
#  id_res                  :integer
#  ps                      :string(255)
#  numero                  :integer
#  fecha                   :datetime
#  leg_ope                 :string(255)
#  apagar_in_cents         :integer
#  saldo_in_cents          :integer
#  dif_in_cents            :integer
#  apagarus_in_cents       :integer
#  saldous_in_cents        :integer
#  difus_in_cents          :integer
#  ret                     :string(255)
#  NOMBRE                  :string(255)
#  nom_ope                 :string(255)
#  moneda                  :string(255)
#  fec_sal                 :datetime
#  DET_PREV                :text(65535)
#  det_prev2               :string(255)
#  marca                   :integer
#  idusumarca              :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  marked                  :boolean          default(FALSE)
#  nombreagencia           :string(255)
#  viajeroresponsable      :string(255)
#  status_service          :integer
#  fec_sen                 :date
#  imp_sen_in_cents        :integer
#  fec_pag                 :date
#  obse_serv               :text(65535)
#  near_expiring_date      :date
#  near_expiring_date_type :string(255)
#  deta                    :text(65535)
#  ope_with_cc             :boolean          default(FALSE)
#  operator_category       :string(255)      not null
#  fec_out                 :date
#  operator_aptour_id      :integer
#  fec_in                  :date
#  provider_aptour_id      :integer
#

class ServiceRegister < ActiveRecord::Base

  # -- Associations
  belongs_to :reserve,
    class_name: 'Reserve',
    primary_key: 'reserve_id',
    foreign_key: 'id_res'
  belongs_to :operator,
    foreign_key: 'operator_aptour_id',
    primary_key: 'aptour_id'
  belongs_to :provider,
    foreign_key: 'provider_aptour_id',
    primary_key: 'aptour_id'

  # -- Misc
  enum operator_category: { national: '1', international: '2' }
  alias_attribute :currency, :moneda

  STATES = [
    ["Borrador", 0],
    ["Confirmado", 1],
    ["Hacer", 2],
    ["Requerido", 3],
    ["Cancelado", 4],
    ["Pedido para cancelar", 7]
  ]

  FEC_TYPES = [
    ["In", 'fec_sal'],
    ["Out", 'fec_out'],
    ["Pago", 'fec_pag'],
    ["Próxima", 'near_expiring_date'],
    ["Seña", 'fec_sen'],
    ["Seña + Pago", 'fec_mix']
  ]

  URGENT_FEC_TYPES = [
    ["Pago", 'fec_pag']
  ]

  # -- Scopes
  scope :ope_with_cc, -> { joins(:operator).where('operators.has_current_account = true') }
  scope :ope_without_cc, -> { joins(:operator).where('operators.has_current_account = false') }
  scope :confirmed, -> { where("status_service = 1") }
  scope :confirmed_with_exception, -> (date_type, from, to) { where("(#{date_type} >= ? AND #{date_type} <= ?) OR (status_service = 1)", from, to) }
  scope :from_operator, -> (id_ope) { where(operator_aptour_id: id_ope) }
  scope :from_national_operator, -> { where("operator_category = 1") }
  scope :from_international_operator, -> { where("operator_category = 2") }
  scope :not_marked, -> { where(marked: false) }
  scope :marked, -> { where(marked: true) }
  scope :with_debt, -> { where('dif_in_cents > 0 || difus_in_cents > 0') }
  scope :with_cred, -> { where('dif_in_cents < 0 || difus_in_cents < 0') }
  scope :not_guardias, -> { where.not("nom_ope LIKE 'GUARDIA%'") }

  # -- Methods
  def payment_group_type
    if self.operator.national?
      'NationalPaymentGroup'
    else
      'InternationalPaymentGroup'
    end
  end

  def self.fec_type_between_dates(fec_type, start_date, end_date)
    return self.where(
      "(fec_pag >= ? AND fec_pag <= ?) OR (fec_sen >= ? AND fec_sen <= ?)",
      start_date,
      end_date,
      start_date,
      end_date
    ) if fec_type == 'fec_mix'

    self.where(
      "#{fec_type} >= ? AND #{fec_type} <= ?",
      start_date,
      end_date
    )
  end

  def service_dif
    dif == 0 ? difus : dif
  end

  def self.attributes_in_cents
    ['apagar','saldo','dif','apagarus','saldous','difus','imp_sen']
  end

  def has_service?
    Service.find_by(
      operator_aptour_id: operator_aptour_id,
      reserve_id: id_res,
      service_number: numero
    ).present?
  end

  def prepaid?
    return false if self.DET_PREV.nil?

    !self.DET_PREV.match(/(prepago|pre\spago|bbe)/i).nil?
  end

  include IntegerInCents
  include CurrencySymbolModule

end
