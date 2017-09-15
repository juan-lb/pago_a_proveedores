class AddOperatorCategoryToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :operator_category, :integer
  end
end
