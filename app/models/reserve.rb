# == Schema Information
#
# Table name: reserves
#
#  id                 :integer          not null, primary key
#  reserve_id         :integer
#  total_in_cents     :integer
#  paid_in_cents      :integer
#  used_in_cents      :integer          default(0)
#  total_usd_in_cents :integer
#  paid_usd_in_cents  :integer
#  used_usd_in_cents  :integer          default(0)
#  agency_aptour_id   :integer
#  id_usu             :string(255)
#  observations       :text(65535)
#  client_details     :text(65535)
#  fec_ape            :date
#  id_operes          :string(255)
#  debt_in_cents      :integer          default(0)
#  debt_usd_in_cents  :integer          default(0)
#

class Reserve < ActiveRecord::Base

  # -- Associations
  belongs_to :agency,
    primary_key: 'aptour_id',
    foreign_key: 'agency_aptour_id'
  belongs_to :user,
    primary_key: 'aptour_id',
    foreign_key: 'id_usu'
  has_many :service_registers,
    class_name: 'ServiceRegister',
    primary_key: 'reserve_id',
    foreign_key: 'id_res'
  has_one :reserve_information
  has_one :operative,
    class_name:  'User',
    primary_key: 'id_operes',
    foreign_key: 'aptour_id'

  # -- Methods
  def self.attributes_in_cents
    ['total','paid','used','total_usd','paid_usd','used_usd', 'debt', 'debt_usd']
  end

  include IntegerInCents

  def self.find(id)
    Reserve.find_by(reserve_id: id)
  end

end
