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

class User < ActiveRecord::Base

  # -- Associations
  has_many :reserves,
    primary_key: 'aptour_id',
    foreign_key: 'id_usu'

  # -- Methods
  def to_s
    name
  end

end
