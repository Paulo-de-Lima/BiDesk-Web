class ItemManutencao < ApplicationRecord
  self.table_name = "itens_manutencao"

  belongs_to :manutencao
  belongs_to :produto

  validates :quantidade, presence: true,
                         numericality: { only_integer: true, greater_than: 0 }
  validates :produto_id, uniqueness: { scope: :manutencao_id, message: "já foi adicionado nesta manutenção" }
  validate :quantidade_disponivel_no_estoque

  before_validation :snapshot_preco, on: :create
  after_create :debitar_estoque
  after_update :ajustar_estoque_se_quantidade_mudou
  after_destroy :restaurar_estoque

  def subtotal
    (preco_unitario || 0) * quantidade
  end

  private

  def snapshot_preco
    return if preco_unitario.present? || produto.blank?

    self.preco_unitario = produto.preco
  end

  def quantidade_disponivel_no_estoque
    return if quantidade.blank? || produto.blank?

    disponivel = produto.quantidade
    if persisted? && !will_save_change_to_produto_id?
      disponivel += quantidade_in_database
    end

    return if quantidade <= disponivel

    errors.add(:quantidade, "excede o estoque disponível (#{disponivel})")
  end

  def debitar_estoque
    produto.decrement!(:quantidade, quantidade)
  end

  def ajustar_estoque_se_quantidade_mudou
    return unless saved_change_to_quantidade?

    delta = quantidade - quantidade_before_last_save
    produto.decrement!(:quantidade, delta)
  end

  def restaurar_estoque
    produto.increment!(:quantidade, quantidade)
  end
end
