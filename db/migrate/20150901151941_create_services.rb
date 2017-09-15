class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.integer :reserve_id
      t.integer :agency_id
      t.string :leg_ope
      t.integer :service_number
      t.integer :amount_in_cents, limit: 8
      t.datetime :date
      t.datetime :date_out
      t.string :viajeroresponsable
      t.references :operator, index: true
      t.references :payment_group, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
