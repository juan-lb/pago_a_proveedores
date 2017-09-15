class AddDetailsToService < ActiveRecord::Migration
  def change
    add_column :services, :details, :text
  end
end
