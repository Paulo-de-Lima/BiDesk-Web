class Manutencao < ApplicationRecord
  validates :equipamento, presence: true
  validates :descricao, presence: true
  validates :data, presence: true
  validates :status, presence: true, inclusion: { in: %w[pendente em_andamento concluida cancelada] }
  validates :custo, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :pendentes, -> { where(status: "pendente") }
  scope :em_andamento, -> { where(status: "em_andamento") }
  scope :concluidas, -> { where(status: "concluida") }
  scope :por_equipamento, ->(eq) { where(equipamento: eq) }
  scope :recentes, -> { order(data: :desc) }

  def concluida?
    status == "concluida"
  end

  def pendente?
    status == "pendente"
  end
end
