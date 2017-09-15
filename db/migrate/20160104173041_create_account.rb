class CreateAccount < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.text :name, null: false
      t.integer :account_api_id, null: false
      t.integer :currency_id
      t.integer :category
    end
  end
end
