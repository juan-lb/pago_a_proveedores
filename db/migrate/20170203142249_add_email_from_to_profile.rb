class AddEmailFromToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :email_from, :string
  end
end
