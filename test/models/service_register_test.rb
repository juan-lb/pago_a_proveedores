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

require 'test_helper'

class ServiceRegisterTest < ActiveSupport::TestCase

  def setup
    @service_register = service_registers(:pesos_debit)
  end

  test "should create a service_register" do
    service_register_pesos   = service_registers(:pesos_debit)
    service_register_dollars = service_registers(:dollars_debit)

    assert_equal service_register_pesos.id_usu, "1"
    assert_equal service_register_dollars.id_usu, "1"
  end

  test 'should have an associated reserve' do
    assert_not_nil @service_register.reserve
  end

  test 'should have an associated operator' do
    assert_not_nil @service_register.operator
  end

end
