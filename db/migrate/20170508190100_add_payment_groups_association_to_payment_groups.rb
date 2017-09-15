class AddPaymentGroupsAssociationToPaymentGroups < ActiveRecord::Migration
  def change
    add_column :payment_groups, :payment_group_id, :integer
    add_column :payment_groups, :fake, :boolean, default: false
  end
end
