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

ActiveRecord::Schema[8.1].define(version: 2026_07_14_151850) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contestants", force: :cascade do |t|
    t.integer "age"
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "occupation"
    t.bigint "person_id", null: false
    t.string "photo_url"
    t.bigint "season_id", null: false
    t.string "tribename"
    t.datetime "updated_at", null: false
    t.string "video_url"
    t.index ["person_id"], name: "index_contestants_on_person_id"
    t.index ["season_id"], name: "index_contestants_on_season_id"
  end

  create_table "episode_scores", force: :cascade do |t|
    t.bigint "contestant_id", null: false
    t.integer "count", default: 1, null: false
    t.datetime "created_at", null: false
    t.integer "episode_number", null: false
    t.integer "points", null: false
    t.bigint "scoring_event_id", null: false
    t.bigint "season_id", null: false
    t.datetime "updated_at", null: false
    t.index ["contestant_id", "episode_number", "scoring_event_id"], name: "index_episode_scores_on_contestant_episode_event", unique: true
    t.index ["contestant_id"], name: "index_episode_scores_on_contestant_id"
    t.index ["scoring_event_id"], name: "index_episode_scores_on_scoring_event_id"
    t.index ["season_id"], name: "index_episode_scores_on_season_id"
  end

  create_table "people", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "gender", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "picks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "female_contestant_id", null: false
    t.integer "golden_goose_contestant_id", null: false
    t.integer "male_contestant_id", null: false
    t.bigint "season_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["female_contestant_id"], name: "index_picks_on_female_contestant_id"
    t.index ["golden_goose_contestant_id"], name: "index_picks_on_golden_goose_contestant_id"
    t.index ["male_contestant_id"], name: "index_picks_on_male_contestant_id"
    t.index ["season_id"], name: "index_picks_on_season_id"
    t.index ["user_id", "season_id"], name: "index_picks_on_user_id_and_season_id", unique: true
    t.index ["user_id"], name: "index_picks_on_user_id"
  end

  create_table "scoring_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "points", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_scoring_events_on_name", unique: true
  end

  create_table "seasons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "number", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_seasons_on_number", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "contestants", "people"
  add_foreign_key "contestants", "seasons"
  add_foreign_key "episode_scores", "contestants"
  add_foreign_key "episode_scores", "scoring_events"
  add_foreign_key "episode_scores", "seasons"
  add_foreign_key "picks", "contestants", column: "female_contestant_id"
  add_foreign_key "picks", "contestants", column: "golden_goose_contestant_id"
  add_foreign_key "picks", "contestants", column: "male_contestant_id"
  add_foreign_key "picks", "seasons"
  add_foreign_key "picks", "users"
end
