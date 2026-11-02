class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  validates :rating,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 5
            }

  validates :body, presence: true, length: { maximum: 2000 }

  validates :user_id, uniqueness: {
    scope: :product_id,
    message: "ви вже залишили відгук на цей товар"
  }
end