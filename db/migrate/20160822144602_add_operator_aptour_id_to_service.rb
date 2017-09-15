class AddOperatorAptourIdToService < ActiveRecord::Migration
  def change
    add_column :services, :operator_aptour_id, :integer
    add_index :services, :operator_aptour_id
  end
end
