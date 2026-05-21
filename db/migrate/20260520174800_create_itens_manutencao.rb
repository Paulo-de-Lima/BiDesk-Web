class CreateItensManutencao < ActiveRecord::Migration[8.1]
  def change
    create_table :itens_manutencao do |t|
      t.references :manutencao, null: false, foreign_key: { to_table: :manutencaos }
      t.references :produto, null: false, foreign_key: true
      t.integer :quantidade, null: false, default: 1
      t.decimal :preco_unitario, precision: 10, scale: 2

      t.timestamps
    end

    add_index :itens_manutencao, [ :manutencao_id, :produto_id ], unique: true
  end
end
