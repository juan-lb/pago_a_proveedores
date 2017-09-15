class AddValidToServices < ActiveRecord::Migration
  def change
    add_column :services, :is_valid, :boolean, default: true
  end
end
