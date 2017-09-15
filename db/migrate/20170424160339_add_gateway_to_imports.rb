class AddGatewayToImports < ActiveRecord::Migration
  def change
    add_column :imports, :gateway, :integer, limit: 1, default: 0
  end
end
