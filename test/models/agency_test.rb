# == Schema Information
#
# Table name: agencies
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  aptour_id :integer
#  color     :string(255)
#

require 'test_helper'
require 'pp'

class AgencyTest < ActiveSupport::TestCase

  def setup
    @agency = agencies(:puerto_aereo)
  end

  test "should create an agency" do
    assert_not_nil @agency.id
  end

  test 'should have associated reserves' do
    assert_not_nil @agency.reserves
  end

  test 'should return agency color' do
    assert_not_nil @agency.agency_color
  end

  test 'should filter agencies by color' do
    ['green', 'red', 'yellow'].each do |color|
      assert_not_nil Agency.send(color)
    end
  end

end
