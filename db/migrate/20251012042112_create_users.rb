# frozen_string_literal: true

# Migration to create the users table with email and password_diges
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, limit: 255, null: false
      t.string :password_digest, limit: 255, null: false
      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
