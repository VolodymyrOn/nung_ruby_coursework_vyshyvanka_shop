class CartItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart
  before_action :set_cart_item, only: [:update, :destroy]

  def create
    product = Product.active.find(params[:product_id])

    size = params[:size].to_s.upcase
    quantity = params[:quantity].to_i

    unless Product::SIZES.include?(size)
      redirect_back fallback_location: products_path,
                    alert: "Оберіть коректний розмір."
      return
    end

    if quantity <= 0 || quantity > 100
      redirect_back fallback_location: products_path,
                    alert: "Кількість повинна бути від 1 до 100."
      return
    end

    @cart.with_lock do
      item = @cart.cart_items.find_or_initialize_by(
        product: product,
        size: size
      )
          
      if item.new_record?
        item.quantity = quantity
      else
        item.quantity += quantity
      end
      
      item.save!
    end

    redirect_to cart_path, notice: "Товар додано до кошика."

  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: products_path,
                  alert: e.record.errors.full_messages.to_sentence

  rescue ActiveRecord::RecordNotFound
    redirect_to products_path, alert: "Товар недоступний."

  end

  def update
    quantity = params.dig(:cart_item, :quantity).to_i

    if quantity <= 0 || quantity > 100
      redirect_to cart_path, alert: "Некоректна кількість."
      return
    end

    @cart_item.update!(quantity: quantity)

    redirect_to cart_path, notice: "Кількість товару оновлено."

  rescue ActiveRecord::RecordInvalid => e
    redirect_to cart_path,
                alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    @cart_item.destroy!

    redirect_to cart_path, notice: "Товар видалено з кошика."
  end

  private

  def set_cart
    @cart = current_user.cart || current_user.create_cart!
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end