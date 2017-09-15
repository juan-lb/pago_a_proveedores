class CreateReserveData < ActiveRecord::Migration
  def change
    create_table :reserves_data do |t|
      t.integer :reserve_id, index: true
      t.integer :total_in_cents, limit: 8
      t.integer :paid_in_cents, limit: 8
      t.integer :used_in_cents, limit: 8, default: 0
      t.integer :total_usd_in_cents, limit: 8
      t.integer :paid_usd_in_cents, limit: 8
      t.integer :used_usd_in_cents, limit: 8, default: 0
    end
  end
end
