# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create(email: 'user@example.com', 
            nickname: 'UOne', 
            name: 'User One', 
            password: "monkey67",
            password_confirmation: "monkey67")

50.times do |n|
  name =  Faker::Name.name
  email = Faker::Internet.email
  phone = "01237546997"
  address = Faker::Address.city
  Customer.create!(
    name: name,
    email: email,
    phone: phone,
    address: address
    )
end

50.times do |n|
  name =  Faker::Food.dish
  code = Faker::Code.imei 
  price = 1000
  category = Faker::Color.color_name
  product = Product.create!(
    name: name,
    code: code,
    category: category,
    default_imported_price: price,
    default_sale_price: price + 1500
    )

  10.times do |m| 
    product.articles.create!(
    status: 'exist',
    imported_price: 1500)
  end
end	

rates = [0, 0.02, 0.05, 0.1, 0.2, 0.5]

rates.each do |rate|
  DiscountedRate.create!(
    rate: rate
  )
end
