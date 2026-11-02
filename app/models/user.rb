class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  ROLES = %w[client admin].freeze

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :restrict_with_error
  has_many :reviews, dependent: :destroy

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :phone, length: { maximum: 25 }, allow_blank: true
  validates :role, inclusion: { in: ROLES }

  def admin?
    role == "admin"
  end

  def client?
    role == "client"
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end
end