class AddProviderToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :provider_aptour_id, :integer
  end
end
