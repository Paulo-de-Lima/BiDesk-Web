class CreateMesasDeBilhar < ActiveRecord::Migration[8.1]
  def change
    create_table :mesas_de_bilhar do |t|
      t.references :cliente, null: false, foreign_key: true
      t.integer :ordem, null: false
      t.string :numeracao, null: false
      t.bigint :registros, null: false, default: 0

      t.timestamps
    end

    add_index :mesas_de_bilhar, [:cliente_id, :ordem], unique: true
  end
end
