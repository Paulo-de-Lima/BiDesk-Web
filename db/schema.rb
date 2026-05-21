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

ActiveRecord::Schema[8.1].define(version: 2026_05_20_180000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "password_digest"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "clientes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "nome"
    t.text "observacoes"
    t.string "telefone"
    t.datetime "updated_at", null: false
  end

  create_table "itens_manutencao", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "manutencao_id", null: false
    t.decimal "preco_unitario", precision: 10, scale: 2
    t.bigint "produto_id", null: false
    t.integer "quantidade", default: 1, null: false
    t.datetime "updated_at", null: false
    t.index ["manutencao_id", "produto_id"], name: "index_itens_manutencao_on_manutencao_id_and_produto_id", unique: true
    t.index ["manutencao_id"], name: "index_itens_manutencao_on_manutencao_id"
    t.index ["produto_id"], name: "index_itens_manutencao_on_produto_id"
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

  add_foreign_key "itens_manutencao", "manutencaos"
  add_foreign_key "itens_manutencao", "produtos"
  add_foreign_key "mesas_de_bilhar", "clientes"
end
