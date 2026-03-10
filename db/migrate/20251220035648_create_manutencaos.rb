class CreateManutencaos < ActiveRecord::Migration[8.1]
  def change
    create_table :manutencaos do |t|
      t.string :equipamento
      t.text :descricao
      t.date :data
      t.decimal :custo
      t.string :status
      t.text :observacoes

      t.timestamps
    end
  end
end
