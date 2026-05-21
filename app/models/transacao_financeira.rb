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
  scope :buscar, ->(termo) { ilike_search(%w[descricao categoria], termo) }

  def self.lista_filtrada(params)
    scope = recentes
    termo = params[:busca].to_s.strip
    scope = scope.buscar(termo) if termo.present?
    scope = scope.where(tipo: params[:tipo]) if params[:tipo].present?
    scope = scope.por_categoria(params[:categoria]) if params[:categoria].present?
    scope
  end

  def self.saldo_mensal(ano, mes)
    receitas.por_mes(ano, mes).sum(:valor) - despesas.por_mes(ano, mes).sum(:valor)
  end
end
