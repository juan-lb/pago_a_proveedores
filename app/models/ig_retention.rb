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

class IgRetention < ActiveRecord::Base

  # -- Associations
  belongs_to :operator,
    primary_key: 'aptour_id',
    foreign_key: 'operator_aptour_id'

  # -- Methods
  def self.attributes_in_cents
    ['accumulated']
  end

  include IntegerInCents
end
