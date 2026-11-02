
class Admin::OrdersController < Admin::BaseController
  include Admin::UnicodeSearch
  before_action :set_order, only: [:show, :update]

  def index
    @orders = Order.includes(:user, :order_items)
                   .order(created_at: :desc)

    if params[:status].present? &&
       Order::STATUSES.include?(params[:status])
      @orders = @orders.where(status: params[:status])
    end

    @orders = unicode_search(
      @orders,
      params[:query],
      :customer_name,
      :customer_email,
      :id
    )
  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def update
    new_status = params.require(:order).fetch(:status).to_s

    unless @order.can_transition_to?(new_status)
      redirect_to admin_order_path(@order),
                  alert: "Недопустима зміна статусу замовлення."
      return
    end

    if new_status == "cancelled"
      OrderInventoryService.cancel!(@order)
    else
      @order.with_lock do
        unless @order.can_transition_to?(new_status)
          raise ActiveRecord::RecordInvalid.new(@order)
        end

        @order.update!(status: new_status)
      end
    end

    redirect_to admin_order_path(@order),
                notice: "Статус замовлення успішно змінено."
  rescue ActiveRecord::RecordInvalid
    redirect_to admin_order_path(@order),
                alert: "Не вдалося змінити статус замовлення."
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end
