class Admin::DashboardController < Admin::BaseController
  def index
    @products_count = Product.count
    @active_products_count = Product.active.count
    @categories_count = Category.count
    @orders_count = Order.count
    @pending_orders_count = Order.where(status: "pending").count
    @users_count = User.where(role: "client").count
    @new_messages_count = ContactMessage.where(status: "new").count

    @recent_orders = Order.includes(:user)
                          .order(created_at: :desc)
                          .limit(5)
  end
end