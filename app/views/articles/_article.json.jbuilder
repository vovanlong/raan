json.extract! article, :id, :quantity, :imported_price
product = Product.find_by_id(article.product_id)
json.extract! product, :name, :code, :category, :default_imported_price, :default_sale_price