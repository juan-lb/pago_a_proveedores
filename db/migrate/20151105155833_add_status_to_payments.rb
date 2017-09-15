class AddStatusToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :status, :string, default: 'Listo'
    add_column :payments, :in_aptour, :boolean, default: false
  end
end
