# frozen_string_literal: true

# Creates the order_items table to link products to orders
class CreateOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true, index: true
      t.references :product, null: false, foreign_key: true, index: true
      t.integer :quantity, null: false, default: 1
      t.decimal :list_price, precision: 10, scale: 2, null: false
      t.decimal :discount, precision: 5, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
