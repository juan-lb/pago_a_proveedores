class AddSellerToService < ActiveRecord::Migration
  def change
    add_column :services, :seller_aptour_id, :string, limit: 4
  end
end
