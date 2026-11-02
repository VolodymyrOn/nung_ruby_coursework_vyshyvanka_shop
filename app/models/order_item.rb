class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :product_title, presence: true
  validates :unit_price, numericality: { greater_than_or_equal_to: 0 }

  validates :size, presence: true, inclusion: { in: Product::SIZES }

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }
end