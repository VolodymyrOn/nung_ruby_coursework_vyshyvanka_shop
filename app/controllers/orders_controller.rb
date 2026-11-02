class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :cancel]

  def index
    @orders = current_user.orders
                          .includes(:order_items)
                          .order(created_at: :desc)
  end

  def new
    @cart = current_user.cart

    if @cart.nil? || @cart.cart_items.empty?
      redirect_to cart_path, alert: "Ваш кошик порожній."
      return
    end

    @order = current_user.orders.new(
      customer_name: current_user.full_name,
      customer_phone: current_user.phone,
      customer_email: current_user.email,
      delivery_method: "nova_poshta",
      payment_method: "cod"
    )
  end

  def create
    @order = OrderInventoryService.new(
      user: current_user,
      attributes: order_params
    ).create!

    redirect_to order_path(@order),
                notice: "Замовлення успішно оформлено!"

  rescue OrderInventoryService::InsufficientStockError => e
    redirect_to cart_path, alert: e.message

  rescue ActiveRecord::RecordInvalid => e
    @order = e.record

    @cart = current_user.cart

    render :new, status: :unprocessable_entity

  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def cancel
    OrderInventoryService.new.cancel!(@order)

    redirect_to order_path(@order),
                notice: "Замовлення скасовано. Товари повернуто на склад."

  rescue OrderInventoryService::CancellationNotAllowedError => e
    redirect_to order_path(@order), alert: e.message
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :customer_name,
      :customer_phone,
      :customer_email,
      :delivery_method,
      :delivery_address,
      :payment_method,
      :notes
    )
  end
end