class AddTemplateToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :report_message, :text
  end
end
