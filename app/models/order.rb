class Order < ApplicationRecord
  STATUSES = %w[
    pending
    confirmed
    shipped
    completed
    cancelled
  ].freeze

  DELIVERY_METHODS = %w[
    nova_poshta
    ukrposhta
    pickup
  ].freeze

  PAYMENT_METHODS = %w[
    card
    cod
  ].freeze

  belongs_to :user

  has_many :order_items, dependent: :restrict_with_exception

  validates :status, inclusion: { in: STATUSES }

  validates :delivery_method, inclusion: { in: DELIVERY_METHODS }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }

  validates :total_amount,
            numericality: { greater_than_or_equal_to: 0 }

  validates :customer_name, presence: true, length: { maximum: 150 }
  validates :customer_phone, presence: true, length: { maximum: 25 }
  validates :customer_email, presence: true

  validates :delivery_address, presence: true, unless: -> { delivery_method == "pickup" }

  validates :notes, length: { maximum: 2000 }, allow_blank: true

  validate :order_must_contain_items, on: :create

  def cancelled?
    status == "cancelled"
  end

  def can_be_cancelled?
    %w[pending confirmed].include?(status)
  end

  def can_be_edited?
    %w[pending confirmed].include?(status)
  end

  def recalculate_total!
    update!(
      total_amount: order_items.sum { |item| item.unit_price * item.quantity }
    )
  end

    def allowed_next_statuses
    case status
    when "pending"
      %w[confirmed cancelled]
    when "confirmed"
      %w[shipped cancelled]
    when "shipped"
      %w[completed]
    else
      []
    end
  end
  
  def can_transition_to?(new_status)
    allowed_next_statuses.include?(new_status.to_s)
  end

  private

  def order_must_contain_items
    if order_items.empty?
      errors.add(:base, "Замовлення повинно містити хоча б один товар")
    end
  end
end