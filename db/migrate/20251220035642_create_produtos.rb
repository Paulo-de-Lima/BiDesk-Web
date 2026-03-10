class CreateProdutos < ActiveRecord::Migration[8.1]
  def change
    create_table :produtos do |t|
      t.string :nome
      t.string :categoria
      t.integer :quantidade
      t.decimal :preco
      t.decimal :valor_minimo
      t.text :descricao

      t.timestamps
    end
  end
end
