# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  key        :string(255)
#  profile_id :integer
#

require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  def setup
    @permission = permissions(:anakin_statistics)
  end

  test 'should create a permission' do
    assert_not_nil @permission.id
  end

  test 'should not create a permission without a profile' do
    permission = Permission.new(key: 'settings')
    permission.valid?

    assert_not permission.save
    assert_includes permission.errors[:profile], 'no puede estar en blanco'
  end

  test 'should not create a permission without a key' do
    permission = Permission.new(profile: profiles(:anakin))
    permission.valid?

    assert_not permission.save
    assert_includes permission.errors[:key], 'no puede estar en blanco'
  end

  test 'should not create a permission with already exists' do
    permission = Permission.new(
      profile: @permission.profile,
      key:     @permission.key
    )
    permission.valid?

    assert_not permission.save
    assert_includes permission.errors[:key], 'ya está en uso'
  end

  test 'should create a permission using an existing key with another profile' do
    permission = Permission.new(
      profile: profiles(:alfonsin),
      key:     @permission.key
    )

    assert permission.save
  end

end
