class AddIgBaseInCentsToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :ig_base_in_cents, :integer, limit: 8
  end
end
