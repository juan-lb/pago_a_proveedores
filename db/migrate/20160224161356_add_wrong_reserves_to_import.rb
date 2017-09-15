class AddWrongReservesToImport < ActiveRecord::Migration
  def change
    add_column :imports, :wrong_reserves, :text
  end
end
