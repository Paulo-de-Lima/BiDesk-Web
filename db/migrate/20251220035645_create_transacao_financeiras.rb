class CreateTransacaoFinanceiras < ActiveRecord::Migration[8.1]
  def change
    create_table :transacao_financeiras do |t|
      t.string :tipo
      t.string :descricao
      t.decimal :valor
      t.date :data
      t.string :categoria

      t.timestamps
    end
  end
end
