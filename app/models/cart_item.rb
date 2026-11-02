class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :size, presence: true, inclusion: { in: Product::SIZES }

  validates :quantity,
            numericality: { only_integer: true, greater_than: 0 }

  validates :product_id,
            uniqueness: {
              scope: [:cart_id, :size],
              message: "цього розміру товар уже є у кошику"
            }

  validate :product_must_be_active

  private

  def product_must_be_active
    return if product.blank? || product.is_active?

    errors.add(:product, "більше недоступний для покупки")
  end
end