class CreateOperatorInformations < ActiveRecord::Migration
  def change
    create_table :operator_informations do |t|
      t.integer :operator_aptour_id
      t.string :email

      t.timestamps null: false
    end
  end
end
