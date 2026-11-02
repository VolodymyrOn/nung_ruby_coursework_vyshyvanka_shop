class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [:edit, :update, :destroy]

  def index
    @categories = Category.includes(:products).order(:name)
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)

    if @category.save
      redirect_to admin_categories_path,
                  notice: "Категорію успішно створено."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_categories_path,
                  notice: "Категорію оновлено."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.products.exists?
      redirect_to admin_categories_path,
                  alert: "Неможливо видалити категорію, у якій є товари."
      return
    end

    @category.destroy!

    redirect_to admin_categories_path,
                notice: "Категорію видалено."
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end