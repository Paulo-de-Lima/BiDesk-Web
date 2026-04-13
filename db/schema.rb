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

ActiveRecord::Schema[8.1].define(version: 2026_04_13_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "clientes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "nome"
    t.text "observacoes"
    t.string "telefone"
    t.datetime "updated_at", null: false
  end

  create_table "manutencaos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "custo"
    t.date "data"
    t.text "descricao"
    t.string "equipamento"
    t.text "observacoes"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "mesas_de_bilhar", force: :cascade do |t|
    t.bigint "cliente_id", null: false
    t.datetime "created_at", null: false
    t.string "numeracao", null: false
    t.integer "ordem", null: false
    t.bigint "registros", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id", "ordem"], name: "index_mesas_de_bilhar_on_cliente_id_and_ordem", unique: true
    t.index ["cliente_id"], name: "index_mesas_de_bilhar_on_cliente_id"
  end

  create_table "produtos", force: :cascade do |t|
    t.string "categoria"
    t.datetime "created_at", null: false
    t.text "descricao"
    t.string "nome"
    t.decimal "preco"
    t.integer "quantidade"
    t.datetime "updated_at", null: false
    t.decimal "valor_minimo"
  end

  create_table "transacao_financeiras", force: :cascade do |t|
    t.string "categoria"
    t.datetime "created_at", null: false
    t.date "data"
    t.string "descricao"
    t.string "tipo"
    t.datetime "updated_at", null: false
    t.decimal "valor"
  end

  add_foreign_key "mesas_de_bilhar", "clientes"
end
