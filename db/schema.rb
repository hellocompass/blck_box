# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141118120527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "connections", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "source_id"
    t.string   "auth_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "connections", ["user_id", "source"], name: "user_source_constraint", unique: true, where: "(((source)::text = (source)::text) AND (user_id = user_id))", using: :btree

  create_table "contents", force: true do |t|
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
  end

  add_index "contents", ["group_id"], name: "index_contents_on_group_id", using: :btree

  create_table "contents_users", force: true do |t|
    t.integer  "content_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contents_users", ["content_id"], name: "index_contents_users_on_content_id", using: :btree
  add_index "contents_users", ["user_id"], name: "index_contents_users_on_user_id", using: :btree

  create_table "emails", force: true do |t|
    t.string  "email"
    t.string  "email_type"
    t.boolean "preferred"
    t.integer "user_id"
  end

  add_index "emails", ["email"], name: "index_emails_on_email", unique: true, using: :btree
  add_index "emails", ["user_id", "preferred"], name: "index_emails_on_user_id_and_preferred", unique: true, where: "(preferred = true)", using: :btree
  add_index "emails", ["user_id"], name: "index_emails_on_user_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled",    default: true
  end

  create_table "groups_users", force: true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id", "group_id"], name: "index_groups_users_on_user_id_and_group_id", unique: true, using: :btree
  add_index "groups_users", ["user_id"], name: "index_groups_users_on_user_id", using: :btree

  create_table "phone_numbers", force: true do |t|
    t.integer "phone_number", limit: 8
    t.string  "number_type"
    t.boolean "preferred"
    t.integer "user_id"
  end

  add_index "phone_numbers", ["phone_number"], name: "index_phone_numbers_on_phone_number", unique: true, using: :btree
  add_index "phone_numbers", ["user_id", "preferred"], name: "index_phone_numbers_on_user_id_and_preferred", unique: true, where: "(preferred = true)", using: :btree
  add_index "phone_numbers", ["user_id"], name: "index_phone_numbers_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "password_digest"
    t.string   "email"
    t.string   "username"
    t.string   "remember_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "pending",         default: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "street_address"
    t.string   "locality"
    t.string   "region"
    t.string   "country"
    t.string   "zip_code"
    t.time     "birthday"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
