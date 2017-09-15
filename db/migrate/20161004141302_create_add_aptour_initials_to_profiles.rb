class CreateAddAptourInitialsToProfiles < ActiveRecord::Migration
  def change
    create_table :add_aptour_initials_to_profiles do |t|
      t.string :aptour_initials

      t.timestamps null: false
    end
  end
end
