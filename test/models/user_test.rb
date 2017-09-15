# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  aptour_id  :string(255)
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = users(:user_one)
  end

  test 'should create an user' do
    assert_not_nil @user.id
  end

  test 'should have associated reserves' do
    assert_equal 3, @user.reserves.count
  end

end
