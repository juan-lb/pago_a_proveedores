class AddFieldsToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :id_usu, :string
    add_column :reserves, :observations, :text
    add_column :reserves, :client_details, :text
  end
end
