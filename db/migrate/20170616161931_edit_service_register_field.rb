class EditServiceRegisterField < ActiveRecord::Migration
  def change
    change_column :service_registers, :DET_PREV, :text
  end
end
