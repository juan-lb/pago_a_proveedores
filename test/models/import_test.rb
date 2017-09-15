# == Schema Information
#
# Table name: imports
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  wrong_reserves     :text(65535)
#  gateway            :integer          default(0)
#  operator_aptour_id :integer          default(-1)
#

require 'test_helper'

class ImportTest < ActiveSupport::TestCase

  test 'should belong to an operator' do
    assert_not_nil imports(:operator).operator
  end

end
