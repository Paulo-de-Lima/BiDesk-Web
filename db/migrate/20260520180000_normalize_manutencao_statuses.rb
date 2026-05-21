class NormalizeManutencaoStatuses < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL.squish
      UPDATE manutencaos
      SET status = 'pendente'
      WHERE status NOT IN ('pendente', 'concluida') OR status IS NULL
    SQL
  end

  def down
  end
end
