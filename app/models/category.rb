class Category < ApplicationRecord
  has_many :products, dependent: :restrict_with_error

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 100 }

  validates :description, length: { maximum: 1000 }, allow_blank: true
end