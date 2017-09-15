class AddOperativeToReserve < ActiveRecord::Migration
  def change
    add_column :reserves, :id_operes, :string
  end
end
