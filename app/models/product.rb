class Product < ApplicationRecord
  SIZES = %w[S M L XL 2XL].freeze

  TARGET_GROUPS = %w[men women girls boys].freeze

  FABRICS = %w[linen cotton homespun].freeze


  has_many_attached :images

  belongs_to :category

  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :restrict_with_exception
  has_many :reviews, dependent: :destroy

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true

  validates :price, numericality: { greater_than_or_equal_to: 0 }

  validates :fabric, presence: true, inclusion: { in: FABRICS }
  validates :color, presence: true, length: { maximum: 100 }
  validates :target_group, presence: true, inclusion: { in: TARGET_GROUPS }

  validates :technique, presence: true, length: { maximum: 100 }

  validates :stock_s, :stock_m, :stock_l, :stock_xl, :stock_2xl,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :is_active, inclusion: { in: [true, false] }

  scope :active, -> { where(is_active: true) }

  scope :search_by_title, ->(query) {
    if query.present?
      q = query.to_s.strip
    
      where(
        "title LIKE :q OR title LIKE :down OR title LIKE :cap OR title LIKE :up",
        q: "%#{sanitize_sql_like(q)}%",
        down: "%#{sanitize_sql_like(q.downcase)}%",
        cap: "%#{sanitize_sql_like(q.capitalize)}%",
        up: "%#{sanitize_sql_like(q.upcase)}%"
      )
    end
  }

  def stock_for(size)
    stock_column = stock_column_for(size)
    return 0 unless stock_column

    public_send(stock_column)
  end

  def stock_column_for(size)
    {
      "S" => :stock_s,
      "M" => :stock_m,
      "L" => :stock_l,
      "XL" => :stock_xl,
      "2XL" => :stock_2xl
    }[size.to_s.upcase]
  end

  def in_stock?
    stock_s.positive? ||
      stock_m.positive? ||
      stock_l.positive? ||
      stock_xl.positive? ||
      stock_2xl.positive?
  end
end