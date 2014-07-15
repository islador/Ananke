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

ActiveRecord::Schema.define(version: 20140712011111) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apis", force: true do |t|
    t.integer  "share_user_id"
    t.integer  "ccp_type"
    t.string   "key_id"
    t.string   "v_code"
    t.integer  "accessmask"
    t.boolean  "active"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "main_entity_name"
    t.integer  "ananke_type"
    t.boolean  "main"
    t.string   "name"
    t.integer  "whitelist_standings"
  end

  create_table "characters", force: true do |t|
    t.integer  "api_id"
    t.string   "name"
    t.integer  "ccp_character_id"
    t.string   "corporationName"
    t.integer  "ccp_corporation_id"
    t.string   "allianceName"
    t.integer  "ccp_alliance_id"
    t.string   "factionName"
    t.integer  "ccp_faction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "main"
    t.integer  "share_id"
  end

  create_table "share_users", force: true do |t|
    t.integer  "share_id"
    t.integer  "user_id"
    t.integer  "user_role"
    t.string   "main_char_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved"
  end

  create_table "shares", force: true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.boolean  "active"
    t.integer  "user_limit"
    t.integer  "grade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "join_link"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "whitelist_api_connections", force: true do |t|
    t.integer  "api_id"
    t.integer  "whitelist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "share_id"
  end

  create_table "whitelist_logs", force: true do |t|
    t.string   "entity_name"
    t.integer  "source_share_user"
    t.integer  "source_type"
    t.boolean  "addition"
    t.integer  "entity_type"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "time"
    t.integer  "share_id"
  end

  create_table "whitelists", force: true do |t|
    t.string   "name"
    t.integer  "standing"
    t.integer  "entity_type"
    t.integer  "source_type"
    t.integer  "source_share_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "share_id"
  end

end
