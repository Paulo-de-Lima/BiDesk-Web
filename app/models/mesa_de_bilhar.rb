class MesaDeBilhar < ApplicationRecord
  self.table_name = "mesas_de_bilhar"

  belongs_to :cliente

  validates :numeracao, presence: true
  validates :ordem, presence: true,
                    numericality: { only_integer: true, greater_than: 0 }
  validates :registros, presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ordem, uniqueness: { scope: :cliente_id }

  before_validation :assign_ordem, on: :create

  private

  def assign_ordem
    return if ordem.present?
    return unless cliente_id

    max = MesaDeBilhar.where(cliente_id: cliente_id).maximum(:ordem)
    self.ordem = (max || 0) + 1
  end
end
