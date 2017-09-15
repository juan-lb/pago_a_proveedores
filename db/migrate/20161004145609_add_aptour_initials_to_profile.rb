class AddAptourInitialsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :aptour_initials, :string, length: 2
  end
end
