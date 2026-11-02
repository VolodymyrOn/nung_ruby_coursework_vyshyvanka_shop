
class Admin::ContactMessagesController < Admin::BaseController
  include Admin::UnicodeSearch
  before_action :set_contact_message, only: [:show, :update, :destroy]

  def index
    @messages = ContactMessage.order(created_at: :desc)

    if ContactMessage::STATUSES.include?(params[:status])
      @messages = @messages.where(status: params[:status])
    end

    @messages = unicode_search(
      @messages,
      params[:query],
      :name,
      :email,
      :subject
    )

    @messages_count = ContactMessage.count
    @new_messages_count = ContactMessage.where(status: "new").count
  end

  def show
    if @contact_message.status == "new"
      @contact_message.update!(status: "read")
    end
  end

  def update
    new_status = params.require(:contact_message).fetch(:status).to_s

    unless ContactMessage::STATUSES.include?(new_status)
      redirect_to admin_contact_message_path(@contact_message),
                  alert: "Невідомий статус звернення."
      return
    end

    if @contact_message.update(status: new_status)
      redirect_to admin_contact_message_path(@contact_message),
                  notice: "Статус звернення оновлено."
    else
      redirect_to admin_contact_message_path(@contact_message),
                  alert: "Не вдалося оновити статус звернення."
    end
  end

  def destroy
    @contact_message.destroy!

    redirect_to admin_contact_messages_path,
                notice: "Звернення видалено."
  end

  private

  def set_contact_message
    @contact_message = ContactMessage.find(params[:id])
  end
end
