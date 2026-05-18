class Cliente < ApplicationRecord
  has_many :mesas_de_bilhar, -> { order(ordem: :asc) },
           class_name: "MesaDeBilhar",
           dependent: :destroy

  validates :nome, presence: true
  validates :telefone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :recentes, -> { order(created_at: :desc) }
  scope :buscar, ->(termo) { where("nome ILIKE ? OR telefone ILIKE ? OR email ILIKE ?", "%#{termo}%", "%#{termo}%", "%#{termo}%") }

  def self.lista_filtrada(params)
    scope = includes(:mesas_de_bilhar)
    scope = scope.buscar(params[:busca]) if params[:busca].present?
    scope = scope.where.not(email: [ nil, "" ]) if params[:com_email] == "1"

    case params[:ordenar]
    when "nome_asc" then scope.order(nome: :asc)
    when "nome_desc" then scope.order(nome: :desc)
    else scope.recentes
    end
  end
end
