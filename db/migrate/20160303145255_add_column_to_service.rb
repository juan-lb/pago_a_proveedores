class AddColumnToService < ActiveRecord::Migration
  def change
    add_column :services, :euros, :float
  end
end
