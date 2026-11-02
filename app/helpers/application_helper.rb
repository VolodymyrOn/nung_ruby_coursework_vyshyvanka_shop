module ApplicationHelper
  include Pagy::Frontend

  def target_group_label(value)
    {
      "men" => "Чоловіки",
      "women" => "Жінки",
      "girls" => "Дівчатка",
      "boys" => "Хлопчики"
    }.fetch(value, value)
  end

  def fabric_label(value)
    {
      "linen" => "Льон",
      "cotton" => "Бавовна",
      "homespun" => "Домоткане полотно"
    }.fetch(value, value)
  end

  def color_label(value)
    value.presence || "Не вказано"
  end

  def order_status_label(status)
    {
      "pending" => "Нове",
      "confirmed" => "Підтверджено",
      "shipped" => "Відправлено",
      "completed" => "Виконано",
      "cancelled" => "Скасовано"
    }.fetch(status, status)
  end
  
  def delivery_method_label(method)
    {
      "nova_poshta" => "Нова Пошта",
      "ukrposhta" => "Укрпошта",
      "pickup" => "Самовивіз"
    }.fetch(method, method)
  end
  
  def payment_method_label(method)
    {
      "card" => "Оплата карткою",
      "cod" => "Післяплата"
    }.fetch(method, method)
  end

  def contact_message_status_label(status)
    {
      "new" => "Нове",
      "read" => "Прочитане",
      "answered" => "Опрацьовано"
    }.fetch(status, status)
  end
end