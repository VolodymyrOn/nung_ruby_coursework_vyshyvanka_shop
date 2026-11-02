admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
admin_password = ENV["ADMIN_PASSWORD"]

if admin_password.blank?
  if Rails.env.development?
    admin_password = "Admin123!"
  else
    raise "Set ADMIN_PASSWORD environment variable before seeding"
  end
end

admin = User.find_or_initialize_by(email: admin_email)

if admin.new_record?
  admin.password = admin_password
  admin.password_confirmation = admin_password
end

admin.first_name = "Адміністратор"
admin.last_name = "Магазину"
admin.role = "admin"

admin.save!

puts "Адміністратор створений або оновлений: #{admin.email}"


categories = [
  {
    name: "Сорочки",
    description: "Традиційні та сучасні вишиті сорочки"
  },
  {
    name: "Сукні",
    description: "Жіночі вишиті сукні"
  },
  {
    name: "Футболки",
    description: "Футболки з українською вишивкою"
  }
]

categories.each do |attributes|
  Category.find_or_create_by!(name: attributes[:name]) do |category|
    category.description = attributes[:description]
  end
end

puts "Початкові категорії створені або вже існують."

categories = {
  "Сорочки" => "Вишиті жіночі та чоловічі сорочки",
  "Сукні" => "Вишиті сукні в українському стилі"
}

categories.each do |name, description|
  Category.find_or_create_by!(name: name) do |category|
    category.description = description
  end
end

shirts = Category.find_by!(name: "Сорочки")
dresses = Category.find_by!(name: "Сукні")
OrderItem.destroy_all
Order.destroy_all
CartItem.destroy_all
Cart.destroy_all
Product.destroy_all
products_data = [
  {
    title: "Молочна сукня «Сонцецвіт»",
    description: "Елегантна вишита сукня молочного кольору з квітковими мотивами. Поєднання українських традицій та сучасного дизайну.",
    price: 11033,
    category: dresses,
    target_group: "women",
    fabric: "linen",
    color: "beige",
    technique: "Машинна вишивка"
  },
  {
    title: "Чорна сукня «Сонцецвіт»",
    description: "Стильна чорна сукня з декоративною українською вишивкою. Підійде для святкових та повсякденних образів.",
    price: 11033,
    category: dresses,
    target_group: "women",
    fabric: "linen",
    color: "black",
    technique: "Машинна вишивка"
  },
  {
    title: "Чорна сорочка «Осердя»",
    description: "Чорна вишита сорочка з виразним етнічним оформленням.",
    price: 9380,
    category: shirts,
    target_group: "women",
    fabric: "linen",
    color: "black",
    technique: "Машинна вишивка"
  },
  {
    title: "Чорна жіноча сорочка «Земля»",
    description: "Жіноча вишита сорочка чорного кольору. Лаконічний дизайн з українськими мотивами.",
    price: 11200,
    category: shirts,
    target_group: "women",
    fabric: "linen",
    color: "black",
    technique: "Машинна вишивка"
  },
  {
    title: "Чорна чоловіча сорочка «Серпень»",
    description: "Чоловіча сорочка у темному кольорі з традиційними мотивами української вишивки.",
    price: 8280,
    category: shirts,
    target_group: "men",
    fabric: "linen",
    color: "black",
    technique: "Машинна вишивка"
  },
  {
    title: "Жіноча блуза «Абрикоси»",
    description: "Жіноча блуза з декоративними мотивами, натхненними українською культурою.",
    price: 11600,
    category: shirts,
    target_group: "women",
    fabric: "cotton",
    color: "beige",
    technique: "Машинна вишивка"
  },
  {
    title: "Вишиванка «Пчілка»",
    description: "Жіноча вишиванка, натхненна орнаментами Ольги Косач.",
    price: 10500,
    category: shirts,
    target_group: "women",
    fabric: "linen",
    color: "white",
    technique: "Машинна вишивка"
  },
  {
    title: "Вишиванка «Єдність»",
    description: "Жіноча вишиванка з орнаментом, присвяченим українським містам-героям.",
    price: 7300,
    category: shirts,
    target_group: "women",
    fabric: "cotton",
    color: "white",
    technique: "Машинна вишивка"
  },
  {
    title: "Вишиванка «Бандура»",
    description: "Вишита сорочка з бежевого льону та декоративним комірцем.",
    price: 10900,
    category: shirts,
    target_group: "women",
    fabric: "linen",
    color: "beige",
    technique: "Машинна вишивка"
  },
  {
    title: "Вишиванка «Бандура Темна»",
    description: "Вишита сорочка з чорного льону та декоративним комірцем.",
    price: 10900,
    category: shirts,
    target_group: "women",
    fabric: "linen",
    color: "black",
    technique: "Машинна вишивка"
  }
]

products_data.each do |data|
  product = Product.find_or_initialize_by(title: data[:title])

  product.assign_attributes(
    description: data[:description],
    price: data[:price],
    category: data[:category],
    target_group: data[:target_group],
    fabric: data[:fabric],
    color: data[:color],
    technique: data[:technique],
    stock_s: 3,
    stock_m: 5,
    stock_l: 5,
    stock_xl: 3,
    stock_2xl: 2,
    is_active: true
  )

  product.save!
end

puts "Каталог наповнено: #{products_data.size} товарів."