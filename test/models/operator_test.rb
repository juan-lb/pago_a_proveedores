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

require 'test_helper'

class OperatorTest < ActiveSupport::TestCase

  def setup
    @operator = operators(:national)
  end

  test 'should create an operator' do
    assert_not_nil @operator.id
  end

  test 'should have associated service_registers' do
    assert_equal 6, @operator.service_registers.count
  end

  test 'should have an associated operator_information' do
    assert_not_nil @operator.information
  end

  test 'should not save operator without aptour_id' do
    operator = Operator.new
    operator.valid?

    assert_includes operator.errors[:aptour_id], 'no puede estar en blanco'
  end

  test 'should not save operator without name' do
    operator = Operator.new
    operator.valid?

    assert_includes operator.errors[:name], 'no puede estar en blanco'
  end

  test 'should not save operator without category' do
    operator = Operator.new
    operator.valid?

    assert_includes operator.errors[:category], 'no puede estar en blanco'
  end

  test 'should have default value for has_ig_retention' do
    operator = Operator.new
    operator.valid?

    assert_not operator.has_ig_retention
  end

end
