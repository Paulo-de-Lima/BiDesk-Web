class Produto < ApplicationRecord
  has_many :itens_manutencao,
           class_name: "ItemManutencao",
           dependent: :restrict_with_error

  validates :nome, presence: true
  validates :quantidade, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :preco, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_minimo, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :buscar, ->(termo) { ilike_search(%w[nome descricao], termo) }
  scope :por_categoria, ->(categoria) { where(categoria: categoria) }
  scope :baixo_estoque, -> { where("quantidade <= valor_minimo") }

  def self.lista_filtrada(params)
    scope = all
    termo = params[:busca].to_s.strip
    scope = scope.buscar(termo) if termo.present?
    scope = scope.por_categoria(params[:categoria]) if params[:categoria].present?
    scope.order(:nome)
  end

  def estoque_baixo?
    quantidade <= valor_minimo
  end
end
