# == Schema Information
#
# Table name: profiles
#
#  id                :integer          not null, primary key
#  email             :string(255)
#  role              :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  operator_category :integer
#  report_message    :text(65535)
#  aptour_initials   :string(255)
#  email_from        :string(255)
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase

  def setup
    @profile = profiles(:alfonsin)
  end

  test 'should have associated payment_groups' do
    assert_not_nil @profile.payment_groups
  end

  test 'should have associated permissions' do
    assert_not_nil @profile.permissions
  end

end
