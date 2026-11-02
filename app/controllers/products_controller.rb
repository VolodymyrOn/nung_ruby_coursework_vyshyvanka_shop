class ProductsController < ApplicationController
  def index
    @categories = Category.order(:name)

    products = Product.active.includes(
      :category,
      images_attachments: :blob
    )

    # Пошук за назвою
    products = products.search_by_title(params[:query])

    # Цільова група
    if Product::TARGET_GROUPS.include?(params[:target_group])
      products = products.where(target_group: params[:target_group])
    end

    # Категорія
    if params[:category_id].present? &&
       params[:category_id].to_s.match?(/\A\d+\z/)
      products = products.where(category_id: params[:category_id])
    end

    # Матеріал
    if Product::FABRICS.include?(params[:fabric])
      products = products.where(fabric: params[:fabric])
    end

    # Техніка вишивки
    if params[:technique].present?
      technique = params[:technique].to_s.strip.first(100)

      unless technique.blank?
        products = products.where(
          "LOWER(products.technique) LIKE ?",
          "%#{Product.sanitize_sql_like(technique.downcase)}%"
        )
      end
    end

    # Мінімальна ціна
    min_price = parse_price(params[:min_price])
    products = products.where("products.price >= ?", min_price) if min_price

    # Максимальна ціна
    max_price = parse_price(params[:max_price])
    products = products.where("products.price <= ?", max_price) if max_price

    @pagy, @products = pagy(
      products.order(created_at: :desc),
      limit: 6
    )
  end

  def show
    @product = Product.active.includes(
      :category,
      images_attachments: :blob,
      reviews: :user
    ).find(params[:id])

    @reviews = @product.reviews.includes(:user).order(created_at: :desc)
    @reviews_count = @reviews.count
    @average_rating = @reviews.average(:rating)&.round(1)
    @user_review = current_user&.reviews&.find_by(product_id: @product.id)
  end

  private

  def parse_price(value)
    return nil if value.blank?

    price = BigDecimal(value.to_s)

    return nil unless price.finite? && price >= 0

    price
  rescue ArgumentError
    nil
  end
end