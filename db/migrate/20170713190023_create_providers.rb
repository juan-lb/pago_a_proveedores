class CreateProviders < ActiveRecord::Migration
  def change
    create_table :providers do |t|
      t.integer :aptour_id
      t.string :name
    end
  end
end
