class AddBankAccountsToOperators < ActiveRecord::Migration
  def change
    add_column :operators, :bank_accounts, :text
  end
end
