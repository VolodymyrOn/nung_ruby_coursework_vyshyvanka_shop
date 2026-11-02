class OrderInventoryService
  class InsufficientStockError < StandardError; end
  class CancellationNotAllowedError < StandardError; end

  def initialize(user: nil, attributes: {})
    @user = user
    @attributes = attributes
  end

  # Створення замовлення та списання залишків
  def create!
    raise ArgumentError, "User is required" unless @user

    order = nil

    ActiveRecord::Base.transaction do
      cart = @user.cart

      raise InsufficientStockError, "Кошик порожній." unless cart

      cart.with_lock do
        cart_items = cart.cart_items.includes(:product).to_a

        raise InsufficientStockError, "Кошик порожній." if cart_items.empty?

        # Створюємо замовлення
        order = @user.orders.build(@attributes)
        total = 0

        cart_items.each do |item|
          product = item.product

          raise InsufficientStockError,
                "Товар «#{product.title}» більше недоступний." unless product.is_active?

          stock_column = product.stock_column_for(item.size)

          unless stock_column
            raise InsufficientStockError, "Некоректний розмір товару."
          end

          # Блокуємо товар на час зміни його залишку
          product.with_lock do
            product.reload

            available = product.public_send(stock_column)

            if available < item.quantity
              raise InsufficientStockError,
                    "Недостатньо товару «#{product.title}», розмір #{item.size}. " \
                    "Доступно: #{available}, потрібно: #{item.quantity}."
            end

            product.update!(stock_column => available - item.quantity)
          end

          # Зберігаємо назву та ціну на момент покупки
          order.order_items.build(
            product: product,
            product_title: product.title,
            unit_price: product.price,
            size: item.size,
            quantity: item.quantity
          )

          total += product.price * item.quantity
        end

        order.total_amount = total
        order.save!

        # Очищуємо кошик тільки після успішного створення замовлення
        cart.cart_items.destroy_all
      end
    end

    order
  end

  # Скасування замовлення та повернення залишків
  def cancel!(order)
    ActiveRecord::Base.transaction do
      order.with_lock do
        order.reload

        unless order.can_be_cancelled?
          raise CancellationNotAllowedError,
                "Це замовлення вже не можна скасувати."
        end

        order.order_items.includes(:product).each do |item|
          product = item.product
          stock_column = product.stock_column_for(item.size)

          unless stock_column
            raise InsufficientStockError,
                  "Не вдалося визначити розмір товару для повернення."
          end

          product.with_lock do
            product.reload

            new_stock = product.public_send(stock_column) + item.quantity

            product.update!(stock_column => new_stock)
          end
        end

        order.update!(
          status: "cancelled",
          cancelled_at: Time.current
        )
      end
    end

    order
  end
end