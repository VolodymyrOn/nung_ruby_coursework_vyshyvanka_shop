
class Admin::ProductsController < Admin::BaseController
  include Admin::UnicodeSearch
  before_action :set_product, only: [:edit, :update, :destroy]

  def index
    @products = Product.includes(:category, images_attachments: :blob)
                       .order(created_at: :desc)

    @products = unicode_search(
      @products,
      params[:query],
      :title
    )

    if params[:category_id].present?
      @products = @products.where(category_id: params[:category_id])
    end

    if params[:status] == "active"
      @products = @products.where(is_active: true)
    elsif params[:status] == "inactive"
      @products = @products.where(is_active: false)
    end

    @categories = Category.order(:name)
  end

  def new
    @product = Product.new(
      is_active: true,
      stock_s: 0,
      stock_m: 0,
      stock_l: 0,
      stock_xl: 0,
      stock_2xl: 0
    )
  end

  def create
    attributes = product_params
    images = attributes.delete(:images)
    attributes.delete(:remove_image_ids)

    @product = Product.new(attributes)

    if @product.save
      @product.images.attach(images) if images.present?

      redirect_to admin_products_path,
                  notice: "Товар успішно створено."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attributes = product_params
    images = attributes.delete(:images)
    remove_image_ids = attributes.delete(:remove_image_ids)

    if @product.update(attributes)
      if images.present?
        @product.images.attach(images)
      end

      if remove_image_ids.present?
        @product.images_attachments
                .where(id: remove_image_ids)
                .each(&:purge)
      end

      redirect_to admin_products_path,
                  notice: "Товар успішно оновлено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.update!(is_active: false)

    redirect_to admin_products_path,
                notice: "Товар деактивовано. Він більше не відображається в каталозі."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :title,
      :description,
      :price,
      :fabric,
      :color,
      :technique,
      :target_group,
      :category_id,
      :is_active,
      :stock_s,
      :stock_m,
      :stock_l,
      :stock_xl,
      :stock_2xl,
      images: [],
      remove_image_ids: []
    )
  end
end
