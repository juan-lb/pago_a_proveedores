class CreateIgRetention < ActiveRecord::Migration
  def change
    create_table :ig_retentions do |t|
      t.integer :id_ope
      t.date :month
      t.integer :accumulated_in_cents, limit: 8, default: 0
    end
  end
end
