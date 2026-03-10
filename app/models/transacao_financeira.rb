class TransacaoFinanceira < ApplicationRecord
  validates :tipo, presence: true, inclusion: { in: %w[receita despesa] }
  validates :descricao, presence: true
  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data, presence: true
  validates :categoria, presence: true

  scope :receitas, -> { where(tipo: "receita") }
  scope :despesas, -> { where(tipo: "despesa") }
  scope :por_mes, ->(ano, mes) { where("EXTRACT(YEAR FROM data) = ? AND EXTRACT(MONTH FROM data) = ?", ano, mes) }
  scope :por_categoria, ->(cat) { where(categoria: cat) }
  scope :recentes, -> { order(data: :desc) }

  def self.saldo_mensal(ano, mes)
    receitas.por_mes(ano, mes).sum(:valor) - despesas.por_mes(ano, mes).sum(:valor)
  end
end
