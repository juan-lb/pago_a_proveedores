# == Schema Information
#
# Table name: agencies
#
#  id        :integer          not null, primary key
#  name      :string(255)
#  aptour_id :integer
#  color     :string(255)
#

class Agency < ActiveRecord::Base

  # -- Associations
  has_many :reserves,
    primary_key: 'aptour_id',
    foreign_key: 'agency_aptour_id'

  # -- Scopes
  scope :green, -> { where("color = 'green'") }
  scope :red, -> { where("color = 'red'") }
  scope :yellow, -> { where("color = 'yellow'") }

  # -- Methods
  def agency_color
    case color
      when "red"
        'danger'
      when "green"
        'success'
      when "yellow"
        'warning'
      else
        'default'
    end
  end

end
