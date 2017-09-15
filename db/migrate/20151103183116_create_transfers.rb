class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.references :payment, index: true, foreign_key: true
      t.integer :reserve_id
      t.boolean :in_aptour, default: false
      t.integer :amount_in_cents, limit: 8
      t.string :error
    end
  end
end
