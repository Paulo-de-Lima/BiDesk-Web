class Produto < ApplicationRecord
  validates :nome, presence: true
  validates :quantidade, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :preco, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_minimo, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :baixo_estoque, -> { where("quantidade <= valor_minimo") }
  scope :por_categoria, ->(cat) { where(categoria: cat) }
  scope :buscar, ->(termo) { where("nome ILIKE ? OR categoria ILIKE ?", "%#{termo}%", "%#{termo}%") }

  def estoque_baixo?
    quantidade <= valor_minimo
  end
end
