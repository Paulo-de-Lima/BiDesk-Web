class Cliente < ApplicationRecord
  has_many :mesas_de_bilhar, -> { order(ordem: :asc) },
           class_name: "MesaDeBilhar",
           dependent: :destroy

  validates :nome, presence: true
  validates :telefone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  scope :recentes, -> { order(created_at: :desc) }
  scope :buscar, ->(termo) { where("nome ILIKE ? OR telefone ILIKE ? OR email ILIKE ?", "%#{termo}%", "%#{termo}%", "%#{termo}%") }
end
