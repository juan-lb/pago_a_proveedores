# == Schema Information
#
# Table name: accounts
#
#  id                 :integer          not null, primary key
#  name               :text(65535)      not null
#  account_api_id     :integer          not null
#  currency_id        :integer
#  category           :integer
#  name_to_show       :string(255)
#  account_type       :string(255)
#  provider_aptour_id :integer
#

class Account < ActiveRecord::Base

  # -- Scopes
  scope :with_category, ->(category) { where("category = ? OR category = ?", category, 3) } #3 es nac/inter

  # -- Misc
  FAKE_PAYMENT_ACCOUNTS = [190, 192, 44, 457, 193, 195, 196, 197, 265, 517, 62, 207]

  # -- Methods
  def self.find_by_api_id(account_id)
    self.find_by(account_api_id: account_id)
  end

  def self.all_accounts
    conn = Connection.new(ENV["APTOUR_URL"])

    conn.get_accounts.body
  end

  def self.all_filter
    all_accounts.map { |x| [ x["NOM_CUE"], x["ID_CUE"] ] }
  end

  def self.all_for_refunds
    conn = Connection.new(ENV["APTOUR_URL"])
    response = conn.get_subaccounts(54)

    return [] if response.status != 200

    response.body.reject { |each| each['oculta'] }
  end

  def self.all_for_fake_payments
    conn     = Connection.new(ENV["APTOUR_URL"])
    response = conn.get_all_accounts

    return [] if response.status != 200

    response.body.
      select { |each| FAKE_PAYMENT_ACCOUNTS.include? each['id_cue'] }.
      reject { |each| each['oculta'] }
  end

  def self.locals_filtered
    Account.all.map { |x| [ x.name, x.account_api_id ]}
  end

  def self.get_account(id)
    conn = Connection.new(ENV["APTOUR_URL"])
    response = conn.get_account(id)
    response.body
  end

  def self.filter_with_category(category)
    with_category(category).map do |each|
      [
        each.name,
        each.account_api_id,
        {'data-account_currency' => each.currency_id}
      ]
    end
  end

  def currency
    case currency_id
    when 1 then "AR$"
    when 2 then "U$D"
    when 3 then "EUR"
    end
  end

  def simple_currency
    case currency_id
    when 1 then 'P'
    when 2 then 'D'
    when 3 then 'E'
    end
  end

  def public_name
    unless name_to_show.nil?
      name_to_show
    else
      name
    end
  end

  def pesos?
    currency_id == 1
  end

  def dollars?
    currency_id == 2
  end

end
