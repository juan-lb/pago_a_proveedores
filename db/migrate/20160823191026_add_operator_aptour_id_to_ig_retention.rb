class AddOperatorAptourIdToIgRetention < ActiveRecord::Migration
  def change
     add_column :ig_retentions, :operator_aptour_id, :integer
     add_index :ig_retentions, :operator_aptour_id
  end
   
end