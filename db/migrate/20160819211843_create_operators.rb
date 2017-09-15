class CreateOperators < ActiveRecord::Migration
  def change
    create_table :operators do |t|
      t.string :name
      t.integer :aptour_id
      t.integer :category # Enumerative
      t.boolean :has_current_account, default: false
      t.boolean :has_ig_retention, default: false
      t.text :detail
      t.string :address
      t.string :cuit

      t.timestamps null: false
    end

    add_index :operators, :aptour_id
  end
end
