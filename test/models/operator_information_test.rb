# == Schema Information
#
# Table name: operator_informations
#
#  id                 :integer          not null, primary key
#  operator_aptour_id :integer
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class OperatorInformationTest < ActiveSupport::TestCase

  def setup
    @operator_information = operator_informations(:one)
  end

  test 'should create an operator_information' do
    assert_not_nil @operator_information.id
  end

  test 'should have an associated operator' do
    assert_not_nil @operator_information.operator
  end

  test 'should not save operator_information without operator_aptour_id' do
    operator_information = OperatorInformation.new
    operator_information.valid?

    assert_includes operator_information.errors[:operator_aptour_id], 'no puede estar en blanco'
  end

  test 'should not save operator_information with an existing operator_aptour_id' do
    operator_information = OperatorInformation.new(
      operator_aptour_id: @operator_information.operator_aptour_id
    )
    operator_information.valid?

    assert_includes operator_information.errors[:operator_aptour_id], 'ya está en uso'
  end

end
