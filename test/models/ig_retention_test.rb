# == Schema Information
#
# Table name: ig_retentions
#
#  id                   :integer          not null, primary key
#  id_ope               :integer
#  month                :date
#  accumulated_in_cents :integer          default(0)
#  operator_aptour_id   :integer
#

require 'test_helper'

class IgRetentionfTest < ActiveSupport::TestCase

  test 'should belong to an opereator' do
    assert_not_nil ig_retentions(:arba).operator
  end

end
