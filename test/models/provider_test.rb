# == Schema Information
#
# Table name: providers
#
#  id        :integer          not null, primary key
#  aptour_id :integer
#  name      :string(255)
#

require 'test_helper'

class ProviderTest < ActiveSupport::TestCase

  def setup
    @provider = providers(:one)
  end

  test 'should create a provider' do
    assert_not_nil @provider.id
  end

  test 'should not create a provider with an existing aptour_id' do
    providers_count = Provider.count

    provider = Provider.create(
      name:      @provider.name,
      aptour_id: @provider.aptour_id,
    )

    assert_not provider.persisted?
    assert_equal providers_count, Provider.count
  end

  test 'should not create a provider without a name' do
    providers_count = Provider.count

    provider = Provider.create(aptour_id: 999)

    assert_not provider.persisted?
    assert_equal providers_count, Provider.count
  end

  test 'should not create a provider without an aptour_id' do
    providers_count = Provider.count

    provider = Provider.create(name: 'Test')

    assert_not provider.persisted?
    assert_equal providers_count, Provider.count
  end

end
