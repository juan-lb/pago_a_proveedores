class AddFieldsToServiceRegister < ActiveRecord::Migration
  def change
    add_column :service_registers, :fec_sen, :date
    add_column :service_registers, :imp_sen_in_cents, :integer, limit: 8
    add_column :service_registers, :fec_pag, :date
    add_column :service_registers, :obse_serv, :text
    add_column :service_registers, :near_expiring_date, :date
    add_column :service_registers, :near_expiring_date_type, :integer, index: true
  end
end
