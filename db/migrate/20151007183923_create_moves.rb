class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.references :operator, index: true
      t.integer :amount_in_cents, limit: 8
      t.references :main_payment, index: true
      t.references :used_payment, index: true
    end
  end
end
