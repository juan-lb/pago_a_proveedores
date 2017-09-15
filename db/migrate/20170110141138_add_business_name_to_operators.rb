class AddBusinessNameToOperators < ActiveRecord::Migration
  def change
    add_column :operators, :business_name, :string
  end
end
