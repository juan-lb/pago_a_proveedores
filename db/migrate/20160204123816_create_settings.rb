class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :ig_limit_in_cents, limit: 8
      t.float :ig_aliquot
    end
  end
end
