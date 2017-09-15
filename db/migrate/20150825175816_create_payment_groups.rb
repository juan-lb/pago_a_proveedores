class CreatePaymentGroups < ActiveRecord::Migration
  def change
    create_table :payment_groups do |t|
      t.string :status
      t.references :profile, index: true, foreign_key: true
      t.references :operator, index: true
      t.integer :total_in_cents, limit: 8, default: 0
      t.string :currency
      t.timestamps null: false
    end
  end
end
