class Users::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = current_user.orders
                          .includes(:order_items)
                          .order(created_at: :desc)
                          .limit(5)

    @orders_count = current_user.orders.count
  end
end