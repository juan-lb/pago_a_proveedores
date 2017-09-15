class AddFieldToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :id_mov_in_aptour, :string
  end
end
