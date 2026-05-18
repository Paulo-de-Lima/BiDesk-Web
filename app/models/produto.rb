class Produto < ApplicationRecord
  validates :nome, presence: true
  validates :quantidade, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :preco, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_minimo, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :buscar, ->(termo) { where("nome ILIKE ? OR descricao ILIKE ?", "%#{termo}%", "%#{termo}%") }
  scope :por_categoria, ->(categoria) { where(categoria: categoria) }
  scope :baixo_estoque, -> { where("quantidade <= valor_minimo") }

  def self.lista_filtrada(params)
    if params[:busca].present?
      buscar(params[:busca]).order(:nome)
    elsif params[:categoria].present?
      por_categoria(params[:categoria]).order(:nome)
    else
      order(:nome)
    end
  end

  def estoque_baixo?
    quantidade <= valor_minimo
  end
end
