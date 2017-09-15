class AddDateInToService < ActiveRecord::Migration
  def change
    add_column :services, :date_in, :datetime
  end
end
