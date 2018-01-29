class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :update, :destroy, :return_order]

  def index
    @orders, @total = Order.get_paginate(params[:page], params[:per_page], params[:search_text])
  end

  def create
    if params[:order][:customer_paid].to_f < 0 
      render_customer_paid_greater_than0 and return 
    end
    
    customer_id = params[:order][:customer_id]
    if customer_id.nil?
      params_customer = params.require(:order).permit(:name, :phone, :email, :address)
      customer = Customer.create!(params_customer)
      customer_id = customer.id
    end
    
    total_amount = 0
    if params[:order_items]
      params[:order_items].each do |item|

        quantity_remain = Import.sum("quantity - quantity_sold")
                                .where("product_id=#{item[:product_id]} and quantity > quantity_sold")

        if quantity_remain < item[:quantity].to_i  
          render_not_enough( product, quantity_remain ) and return
        end
        if item[:quantity].to_i <= 0 
          render_quantity_greater_than0 and return 
        end
      end

      @order = Order.create!(customer_id: customer_id, customer_paid: params[:order][:customer_paid].to_f)

      params[:order_items].each do |item| 

        order_item = @order.order_items.create!(quantity:         item[:quantity], 
                                                discounted_rate:  item[:discounted_rate],
                                                product_id:       item[:product_id])
        order_item.calculate_amount(item[:price_sale].to_f)
        total_amount += order_item.amount

        sold_in_import(item[:product_id], item[:quantity].to_i)
      end
    end
    
    @order.update_attributes(total_amount: total_amount)
    @order.set_fully_paid
    render json: { order: @order }, status: :created
  end

  def show 

  end

  def update 
    @order.pay_debt(params[:payment].to_f)
    render 'orders/show.json.jbuilder'
  end

  def return_order
    order_items = @order.order_items
    params[:order_items].each do |item|
      order_item = OrderItem.find_by_id(item[:id])
      articles_be_sold = order_item.articles.order(created_at: :desc)

      # Return article 
      item[:quantity_return].to_i.times do |n| 
        articles_be_sold[n].beReturn
      end
      if ( item[:quantity_return].to_i == order_item.quantity )
        order_item.destroy
      else
        order_item.return_calculate_after_return(item[:quantity_return].to_i)
      end
      
    end

    total_amount = @order.total_amount
    customer_paid = @order.customer_paid
    new_total_amount = @order.order_items.sum(:amount).round(-2)
    @paid_return_user = 0 

    if new_total_amount < @order.customer_paid
      @paid_return_user = @order.customer_paid - new_total_amount
      customer_paid = new_total_amount
    end
    
    @order.calculate_total_amount
    @order.customer_paid =  customer_paid
    @order.save
    @order.set_fully_paid
    
    render 'orders/return_order'
  end

  def destroy 
    @order.destroy 
    head :ok
  end

  def search
    @orders = Order.joins("inner join customers on customers.id = orders.customer_id")
                   .select("orders.id as id, orders.created_at as created_at, name, email, phone, address")
                   .order("orders.created_at")
    render 'orders/search'
  end

  def quote
    OrderMailer.quote_price(params[:email], params[:code_html]).deliver_now
  end

  private 

  def set_order 
    @order = Order.find_by_id(params[:id])
    if @order.nil? 
      render json: { message: 'Not found'}, status: :not_found
    end
  end


  def sold_in_import(product_id, quantity)
    imports = Import.select("*")
                    .where("product_id=#{product_id} and quantity > quantity_sold")
                    .order(create_at: :desc)

    imports.each do |import|
      if (import.quantity - import.quantity_sold) >= quantity 
        
      end
    end
  end

  def render_not_enough(product, quantity)
    render( json: { key_message: "message.new-order.not-enough-quantity", params: { name: product.name, quantity: quantity } }, status: :unprocessable_entity )    
  end

  def render_quantity_greater_than0
    render( json: { key_message: "message.new-order.quantity_greater_than0" }, status: :unprocessable_entity )        
  end

  def render_customer_paid_greater_than0
    render( json: { key_message: "message.new-order.customer_paid_greater_than_1" }, status: :unprocessable_entity )            
  end
end
