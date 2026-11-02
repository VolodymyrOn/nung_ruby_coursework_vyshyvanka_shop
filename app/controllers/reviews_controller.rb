class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product
  before_action :set_review, only: [:update, :destroy]
  before_action :authorize_review!, only: [:update]
  before_action :authorize_review_or_admin!, only: [:destroy]

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      redirect_to product_path(@product, anchor: "reviews"),
                  notice: "Ваш відгук успішно додано."
    else
      redirect_to product_path(@product, anchor: "review-form"),
                  alert: @review.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordNotUnique
    redirect_to product_path(@product, anchor: "reviews"),
                alert: "Ви вже залишили відгук на цей товар."
  end

  def update
    if @review.update(review_params)
      redirect_to product_path(@product, anchor: "reviews"),
                  notice: "Ваш відгук оновлено."
    else
      redirect_to product_path(@product, anchor: "reviews"),
                  alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review.destroy!

    redirect_to product_path(@product, anchor: "reviews"),
                notice: "Відгук видалено."
  end

  private

  def set_product
    @product = Product.active.find(params[:product_id])
  end

  def set_review
    @review = @product.reviews.find(params[:id])
  end

  def authorize_review!
    return if @review.user_id == current_user.id

    redirect_to product_path(@product),
                alert: "Ви можете редагувати лише власні відгуки."
  end

  def authorize_review_or_admin!
    return if @review.user_id == current_user.id || current_user.admin?

    redirect_to product_path(@product),
                alert: "У вас немає прав для видалення цього відгуку."
  end

  def review_params
    params.require(:review).permit(:rating, :body)
  end
end