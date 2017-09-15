# == Schema Information
#
# Table name: providers
#
#  id        :integer          not null, primary key
#  aptour_id :integer
#  name      :string(255)
#

class Provider < ActiveRecord::Base

  has_many :service_registers,
    foreign_key: 'provider_aptour_id',
    primary_key: 'aptour_id'
  has_many :services,
    foreign_key: 'provider_aptour_id',
    primary_key: 'aptour_id'

  validates_presence_of :name, :aptour_id
  validates_uniqueness_of :aptour_id

end
