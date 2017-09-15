class CreatePaymentGroupReport < ActiveRecord::Migration
  def change
    create_table :payment_group_reports do |t|
      t.references :payment_group, index: true, foreign_key: true
      t.text :note
      t.text :swift
      t.integer :printable_column, default: 1
    end
  end
end
