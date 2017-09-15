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

class Profile < ActiveRecord::Base

  # -- Associations
  has_many :payment_groups
  has_many :permissions, dependent: :destroy

  # -- Validations
  validates :role, presence: true
  validates :email, presence: true
  validates_format_of :email,
    :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

  # -- Misc
  enum operator_category: {national: 1, international: 2, aerials: 3}

  OPERATOR_CATEGORY = %w(national international)
  ROLES             = %w(admin user)

  # -- Methods
  def is?(role_name)
    if has_role?
      role == role_name
    else
      false
    end
  end

  def has_role?
    role.present?
  end

  def works_with_national_operator?
    operator_category == 'national'
  end

  def has_permissions?(controller)
    return true if is? 'admin'

    permissions.where(key: controller).present?
  end

end
