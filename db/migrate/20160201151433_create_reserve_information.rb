class CreateReserveInformation < ActiveRecord::Migration
  def change
    create_table :reserve_informations do |t|
      t.integer :reserve_id, null: false
      t.integer :available_ars_in_cents, limit: 8
      t.integer :accumulated_ars_in_cents, limit: 8
      t.integer :available_usd_in_cents, limit: 8
      t.integer :accumulated_usd_in_cents, limit: 8
    end
  end
end