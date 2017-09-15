class AccountsGenerator

  def initialize(accounts)
    @accounts = accounts
  end

  def call
    @accounts.each { |id| create_account(id) }
  end

  private

  def create_account(id)
    Account.where(account_api_id: id).first_or_create do |new_account|
      account = Account.get_account(id)

      new_account.name =           account["name"]
      new_account.account_api_id = account["id"]
      new_account.currency_id =    account["currency_id"]
      new_account.account_type =   account["type"]
    end
  end

end
