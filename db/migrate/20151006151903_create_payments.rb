class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :total_payment_in_cents, limit: 8
      t.integer :principal_reserve_id
      t.references :payment_group, index: true, foreign_key: true
      
    end
  end
end
