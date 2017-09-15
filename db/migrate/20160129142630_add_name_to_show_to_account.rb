class AddNameToShowToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :name_to_show, :string
  end
end
