# frozen_string_literal: true

# Migration to create the categories table for product categorization
class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name

      t.timestamps
    end
  end
end
