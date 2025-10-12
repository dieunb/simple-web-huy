# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 20_251_012_051_234) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_catalog.plpgsql'

  create_table 'order_items', force: :cascade do |t|
    t.bigint 'order_id', null: false
    t.bigint 'product_id', null: false
    t.integer 'quantity', default: 1, null: false
    t.decimal 'list_price', precision: 10, scale: 2, null: false
    t.decimal 'discount', precision: 5, scale: 2, default: '0.0'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['order_id'], name: 'index_order_items_on_order_id'
    t.index ['product_id'], name: 'index_order_items_on_product_id'
  end

  create_table 'orders', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'status', null: false
    t.date 'order_date'
    t.date 'required_date'
    t.date 'shipped_date'
    t.integer 'store_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['order_date'], name: 'index_orders_on_order_date'
    t.index ['user_id'], name: 'index_orders_on_user_id'
  end

  create_table 'products', force: :cascade do |t|
    t.string 'name'
    t.string 'brand'
    t.integer 'category_id'
    t.integer 'year'
    t.decimal 'price'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['brand'], name: 'index_products_on_brand'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email', limit: 255, null: false
    t.string 'password_digest', limit: 255, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
  end

  add_foreign_key 'order_items', 'orders'
  add_foreign_key 'order_items', 'products'
end
