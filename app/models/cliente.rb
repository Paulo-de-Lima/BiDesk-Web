class Cliente < ApplicationRecord
  has_many :mesas_de_bilhar, -> { order(ordem: :asc) },
           class_name: "MesaDeBilhar",
           dependent: :destroy

  validates :nome, presence: true
  validates :telefone, presence: true,
                       format: { with: /\A\(\d{2}\) \d{4,5}-\d{4}\z/, message: "use o formato (00) 00000-0000" }

  before_validation :normalizar_telefone
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :recentes, -> { order(created_at: :desc) }
  scope :buscar, ->(termo) { ilike_search(%w[nome telefone email], termo) }

  def self.lista_filtrada(params)
    scope = includes(:mesas_de_bilhar)
    termo = params[:busca].to_s.strip
    scope = scope.buscar(termo) if termo.present?
    scope = scope.where.not(email: [ nil, "" ]) if params[:com_email] == "1"

    case params[:ordenar]
    when "nome_asc" then scope.order(nome: :asc)
    when "nome_desc" then scope.order(nome: :desc)
    else scope.recentes
    end
  end

  private

  def normalizar_telefone
    return if telefone.blank?

    digits = telefone.gsub(/\D/, "")
    return unless digits.length.in?(10..11)

    self.telefone = if digits.length == 10
      format("(%<ddd>s) %<p1>s-%<p2>s", ddd: digits[0, 2], p1: digits[2, 4], p2: digits[6, 4])
    else
      format("(%<ddd>s) %<p1>s-%<p2>s", ddd: digits[0, 2], p1: digits[2, 5], p2: digits[7, 4])
    end
  end
end
