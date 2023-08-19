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

ActiveRecord::Schema[7.0].define(version: 2023_08_19_080449) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "chatroom_users", force: :cascade do |t|
    t.bigint "chatroom_id"
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["chatroom_id"], name: "index_chatroom_users_on_chatroom_id"
    t.index ["user_id"], name: "index_chatroom_users_on_user_id"
  end

  create_table "chatrooms", force: :cascade do |t|
    t.string "gameaable_type"
    t.uuid "gameaable_id"
    t.string "topic"
    t.boolean "public", default: true
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["gameaable_type", "gameaable_id"], name: "index_chatrooms_on_gameaable_type_and_gameaable_id"
    t.index ["public"], name: "index_chatrooms_on_public"
    t.index ["topic"], name: "index_chatrooms_on_topic"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.uuid "game_id"
    t.bigint "team_id"
    t.boolean "host", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "invitation_accepted", default: false
    t.string "playerable_type"
    t.bigint "playerable_id"
    t.string "player_name"
    t.string "ip_address"
    t.jsonb "scores"
    t.index ["game_id"], name: "index_game_sessions_on_game_id"
    t.index ["host"], name: "index_game_sessions_on_host"
    t.index ["invitation_accepted"], name: "index_game_sessions_on_invitation_accepted"
    t.index ["playerable_type", "playerable_id"], name: "index_game_sessions_on_playerable_type_and_playerable_id"
    t.index ["team_id"], name: "index_game_sessions_on_team_id"
  end

  create_table "games", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string "name"
    t.jsonb "set"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "started", default: false
    t.boolean "ended", default: false
    t.boolean "team_mode", default: false
    t.string "password_digest"
    t.jsonb "turn_order"
    t.jsonb "options"
    t.jsonb "interactions"
    t.index ["name"], name: "index_games_on_name"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chatroom_id"
    t.string "content"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "speakerable_type"
    t.bigint "speakerable_id"
    t.index ["chatroom_id"], name: "index_messages_on_chatroom_id"
    t.index ["speakerable_type", "speakerable_id"], name: "index_messages_on_speakerable_type_and_speakerable_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "ip_address"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["ip_address"], name: "index_players_on_ip_address"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "order"
    t.uuid "game_id"
    t.jsonb "scores"
    t.index ["game_id"], name: "index_teams_on_game_id"
    t.index ["name"], name: "index_teams_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.boolean "admin"
    t.string "avatar"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "chatroom_users", "chatrooms"
  add_foreign_key "chatroom_users", "users"
  add_foreign_key "game_sessions", "games"
  add_foreign_key "game_sessions", "teams"
  add_foreign_key "messages", "chatrooms"
end
