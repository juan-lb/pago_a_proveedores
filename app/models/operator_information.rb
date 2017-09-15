# == Schema Information
#
# Table name: operator_informations
#
#  id                 :integer          not null, primary key
#  operator_aptour_id :integer
#  email              :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class OperatorInformation < ActiveRecord::Base

  # -- Associations
  belongs_to :operator,
    primary_key: 'aptour_id',
    foreign_key: 'operator_aptour_id'

  # -- Validations
  validates :operator_aptour_id, uniqueness: true, presence: true

end
