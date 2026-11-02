class CartsController < ApplicationController
  before_action :authenticate_user!

  def show
    @cart = current_user.cart || current_user.create_cart!
    @cart_items = @cart.cart_items.includes(product: [
      :category,
      { images_attachments: :blob }
    ])
  end

  def destroy
    cart = current_user.cart

    cart&.cart_items&.destroy_all

    redirect_to cart_path, notice: "Кошик очищено."
  end
end