class AddOperatorToImport < ActiveRecord::Migration
  def change
    add_column :imports, :operator_aptour_id, :integer, default: -1
  end
end
