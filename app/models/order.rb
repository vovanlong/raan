class Order < ApplicationRecord
  before_create{ self.id = private_id }
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  validates_presence_of :customer_paid
  validates :customer_paid, numericality: { greater_than: 0 }

  def set_fully_paid
    if (customer_paid >= self.total_amount) 
      self.fully_paid = true;
    end

    self.save
  end

  def debt 
    if fully_paid?
      0
    else
      self.total_amount - self.customer_paid 
    end
  end

  def pay_debt(payment) 
    self.customer_paid += payment 
    if (self.customer_paid >= self.total_amount) 
      self.fully_paid = true;
    end

    self.save
  end

  def calculate_total_amount
    self.total_amount = self.order_items.sum(:amount)
    self.save
  end

  def self.get_paginate(page, per_page) 
    if page
      @donhang = Order.joins("inner join customers on customers.id = orders.customer_id")
          .select("orders.*, name, email, phone, address")
          .order("orders.created_at desc")            
          .paginate(:page => page, :per_page => per_page)
      @total = Order.count
    else
      @donhang = Order.joins("inner join customers on customers.id = orders.customer_id")
                .select("orders.*, name, email, phone, address")
                .order("orders.created_at desc")
      @total = Order.count
    end
    return @donhang, @total
  end
end
