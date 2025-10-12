# frozen_string_literal: true

# Creates orders table to store customer order information
class CreateOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :orders do |table|
      add_reference_columns(table)
      add_date_columns(table)
      table.timestamps
    end
    add_index :orders, :user_id
  end

  def add_reference_columns(table)
    table.integer :user_id, null: false
    table.integer :status, null: false
    table.integer :store_id
  end

  def add_date_columns(table)
    table.date :order_date
    table.date :required_date
    table.date :shipped_date
  end
end
