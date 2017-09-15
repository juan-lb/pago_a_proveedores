class AddImportationRunningToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :importation_running, :boolean, default: false
  end
end
