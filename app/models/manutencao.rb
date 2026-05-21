class Manutencao < ApplicationRecord
  has_many :itens_manutencao,
           class_name: "ItemManutencao",
           dependent: :destroy,
           inverse_of: :manutencao
  has_many :produtos, through: :itens_manutencao

  accepts_nested_attributes_for :itens_manutencao,
                                allow_destroy: true,
                                reject_if: ->(attrs) { attrs["produto_id"].blank? }

  validates :equipamento, presence: true
  validates :descricao, presence: true
  validates :data, presence: true
  STATUSES = %w[pendente concluida].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pendentes, -> { where(status: "pendente") }
  scope :concluidas, -> { where(status: "concluida") }
  scope :por_equipamento, ->(eq) { where(equipamento: eq) }
  scope :recentes, -> { order(data: :desc) }
  scope :buscar, ->(termo) { ilike_search(%w[equipamento descricao observacoes], termo) }

  def total_itens_estoque
    itens_manutencao.sum(&:subtotal)
  end

  def self.lista_filtrada(params)
    scope = includes(itens_manutencao: :produto).recentes
    termo = params[:busca].to_s.strip
    scope = scope.buscar(termo) if termo.present?
    scope = scope.where(status: params[:status]) if params[:status].present?
    scope = scope.por_equipamento(params[:equipamento]) if params[:equipamento].present?
    scope
  end

  def concluida?
    status == "concluida"
  end

  def pendente?
    status == "pendente"
  end
end
