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

ActiveRecord::Schema.define(version: 20170110153253) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "constraint_sets", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.integer  "min_calories",            default: 0
    t.integer  "target_calories",         default: 0
    t.integer  "max_calories",            default: 999999
    t.decimal  "min_fat",                 default: "0.0"
    t.decimal  "target_fat",              default: "0.0"
    t.decimal  "max_fat",                 default: "999999.0"
    t.decimal  "min_carbohydrates",       default: "0.0"
    t.decimal  "target_carbohydrates",    default: "0.0"
    t.decimal  "max_carbohydrates",       default: "999999.0"
    t.decimal  "min_protein",             default: "0.0"
    t.decimal  "target_protein",          default: "0.0"
    t.decimal  "max_protein",             default: "999999.0"
    t.integer  "daily_constraint_set_id"
    t.integer  "position"
    t.string   "type"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "meal_plan_input_id"
    t.boolean  "primary",                 default: false
    t.date     "used_at"
    t.index ["user_id"], name: "index_constraint_sets_on_user_id", using: :btree
  end

  create_table "directions", force: :cascade do |t|
    t.text     "step"
    t.integer  "recipe_id"
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "excluded_foods", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "foods_by_source_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["foods_by_source_id"], name: "index_excluded_foods_on_foods_by_source_id", using: :btree
  end

  create_table "foods", force: :cascade do |t|
    t.string   "title",         default: ""
    t.decimal  "calories",      default: "0.0"
    t.decimal  "fat",           default: "0.0"
    t.decimal  "carbohydrates", default: "0.0"
    t.decimal  "protein",       default: "0.0"
    t.integer  "user_id"
    t.string   "type"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "published_at"
    t.decimal  "price"
  end

  create_table "foods_by_sources", force: :cascade do |t|
    t.integer  "sources_by_meal_id"
    t.integer  "source_id"
    t.boolean  "all"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["sources_by_meal_id"], name: "index_foods_by_sources_on_sources_by_meal_id", using: :btree
  end

  create_table "included_food_amounts", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "foods_by_source_id"
    t.decimal  "amount"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["foods_by_source_id"], name: "index_included_food_amounts_on_foods_by_source_id", using: :btree
  end

  create_table "included_foods", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "foods_by_source_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["foods_by_source_id"], name: "index_included_foods_on_foods_by_source_id", using: :btree
  end

  create_table "ingredients", force: :cascade do |t|
    t.integer  "recipe_id"
    t.integer  "food_id"
    t.decimal  "amount",     default: "0.0"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "measure",    default: "unit"
  end

  create_table "locations", force: :cascade do |t|
    t.integer  "street_number"
    t.string   "route"
    t.string   "neighborhood"
    t.string   "locality"
    t.string   "administrative_area_level_1"
    t.string   "administrative_area_level_2"
    t.string   "administrative_area_level_3"
    t.string   "country"
    t.integer  "postal_code"
    t.string   "formatted_address"
    t.decimal  "lat"
    t.decimal  "lng"
    t.string   "place_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "type"
    t.integer  "restaurant_id"
  end

  create_table "meal_items", force: :cascade do |t|
    t.integer  "meal_id"
    t.integer  "food_id"
    t.decimal  "amount",     default: "0.0"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "measure",    default: "unit"
    t.index ["food_id"], name: "index_meal_items_on_food_id", using: :btree
    t.index ["meal_id"], name: "index_meal_items_on_meal_id", using: :btree
  end

  create_table "meal_plan_inputs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "meal_plans", force: :cascade do |t|
    t.string   "title",         default: ""
    t.integer  "user_id"
    t.datetime "published_at"
    t.decimal  "calories",      default: "0.0"
    t.decimal  "fat",           default: "0.0"
    t.decimal  "carbohydrates", default: "0.0"
    t.decimal  "protein",       default: "0.0"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.date     "used_at"
    t.index ["user_id"], name: "index_meal_plans_on_user_id", using: :btree
  end

  create_table "meals", force: :cascade do |t|
    t.string   "title",         default: ""
    t.integer  "user_id"
    t.decimal  "calories",      default: "0.0"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "published_at"
    t.decimal  "fat",           default: "0.0"
    t.decimal  "carbohydrates", default: "0.0"
    t.decimal  "protein",       default: "0.0"
    t.integer  "meal_plan_id",  default: 1
    t.date     "used_at"
    t.integer  "position"
    t.index ["user_id"], name: "index_meals_on_user_id", using: :btree
  end

  create_table "menu_item_ingredients", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "menu_item_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "menu_item_join_menu_items", force: :cascade do |t|
    t.integer "menu_id"
    t.integer "menu_item_id"
  end

  create_table "menu_join_menu_items", force: :cascade do |t|
    t.integer "menu_id"
    t.integer "menu_item_id"
  end

  create_table "pantries", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_pantries_on_user_id", using: :btree
  end

  create_table "pantry_items", force: :cascade do |t|
    t.integer  "pantry_id"
    t.integer  "food_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal  "amount"
    t.index ["food_id"], name: "index_pantry_items_on_food_id", using: :btree
    t.index ["pantry_id"], name: "index_pantry_items_on_pantry_id", using: :btree
  end

  create_table "restaurant_join_menu_items", force: :cascade do |t|
    t.integer  "restaurant_id"
    t.integer  "menu_item_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "restaurant_join_menus", force: :cascade do |t|
    t.integer  "restaurant_id"
    t.integer  "menu_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "shopping_list_items", force: :cascade do |t|
    t.integer  "food_id"
    t.integer  "shopping_list_id"
    t.decimal  "amount"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["food_id"], name: "index_shopping_list_items_on_food_id", using: :btree
    t.index ["shopping_list_id"], name: "index_shopping_list_items_on_shopping_list_id", using: :btree
  end

  create_table "shopping_lists", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_shopping_lists_on_user_id", using: :btree
  end

  create_table "source_items", force: :cascade do |t|
    t.integer  "source_id"
    t.integer  "food_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["food_id"], name: "index_source_items_on_food_id", using: :btree
    t.index ["source_id"], name: "index_source_items_on_source_id", using: :btree
  end

  create_table "sources", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "type"
    t.integer  "source_id"
    t.string   "category"
    t.boolean  "personal",   default: false
  end

  create_table "sources_by_meals", force: :cascade do |t|
    t.integer  "meal_plan_input_id"
    t.integer  "position"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["meal_plan_input_id"], name: "index_sources_by_meals_on_meal_plan_input_id", using: :btree
  end

  create_table "user_join_sources", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source_id"], name: "index_user_join_sources_on_source_id", using: :btree
    t.index ["user_id"], name: "index_user_join_sources_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "auth_token",             default: ""
    t.integer  "age"
    t.string   "gender"
    t.decimal  "weight"
    t.decimal  "feet"
    t.decimal  "inches"
    t.integer  "eer"
    t.string   "activity_level"
    t.string   "first_name",             default: ""
    t.string   "last_name",              default: ""
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "constraint_sets", "users"
  add_foreign_key "excluded_foods", "foods_by_sources"
  add_foreign_key "foods_by_sources", "sources_by_meals"
  add_foreign_key "included_food_amounts", "foods_by_sources"
  add_foreign_key "included_foods", "foods_by_sources"
  add_foreign_key "pantries", "users"
  add_foreign_key "pantry_items", "foods"
  add_foreign_key "pantry_items", "pantries"
  add_foreign_key "shopping_list_items", "foods"
  add_foreign_key "shopping_list_items", "shopping_lists"
  add_foreign_key "shopping_lists", "users"
  add_foreign_key "source_items", "foods"
  add_foreign_key "source_items", "sources"
  add_foreign_key "sources_by_meals", "meal_plan_inputs"
  add_foreign_key "user_join_sources", "sources"
  add_foreign_key "user_join_sources", "users"
end
