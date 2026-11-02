class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new

    if user_signed_in?
      @contact_message.name = current_user.full_name
      @contact_message.email = current_user.email
    end
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)

    if @contact_message.save
      redirect_to root_path,
                  notice: "Ваше звернення успішно надіслано. Дякуємо!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(
      :name,
      :email,
      :subject,
      :body
    )
  end
end