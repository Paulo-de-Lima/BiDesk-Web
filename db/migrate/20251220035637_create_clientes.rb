class CreateClientes < ActiveRecord::Migration[8.1]
  def change
    create_table :clientes do |t|
      t.string :nome
      t.string :telefone
      t.string :email
      t.text :observacoes

      t.timestamps
    end
  end
end
