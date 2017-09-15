class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :key
      t.integer :profile_id
    end
  end
end
