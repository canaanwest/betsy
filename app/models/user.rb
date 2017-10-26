class User < ApplicationRecord
  has_many :products
  has_many :orders
  has_many :reviews

  belongs_to :billing_datum, optional: true

  validates :username, presence: true
  validates :username, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def merchant_entries
    products = self.products
    merchant_entries = []
    products.each do |product|
      entries = OrderProduct.where(product_id: product.id)
      entries.each { |entry| merchant_entries << entry if !(entry.pending?)}
    end
    return merchant_entries if merchant_entries.first != nil
    return false
  end

  def paid_entries
    entries = self.merchant_entries
    paid_entries = []
    entries.each do |entry|
      paid_entries << entry if entry.paid?
    end
    return paid_entries if paid_entries.first != nil
    return false
  end

  def shipped_entries
    entries = self.merchant_entries
    shipped_entries = []
    entries.each do |entry|
      shipped_entries << entry if entry.shipped?
    end
    return shipped_entries if shipped_entries.first != nil
    return false
  end

  def canceled_entries
    entries = self.merchant_entries
    canceled_entries = []
    entries.each do |entry|
      canceled_entries << entry if entry.canceled?
    end
    return canceled_entries if canceled_entries.first != nil
    return false
  end

  def canceled_revenue
    entries = canceled_entries
    subtotal = 0
    if entries
      entries.each do |entry|
        subtotal += entry.subtotal
      end
    end
    return subtotal
  end

  def shipped_revenue
    entries = shipped_entries
    subtotal = 0
    if entries
      entries.each do |entry|
        subtotal += entry.subtotal
      end
    end
    return subtotal
  end


  def paid_revenue
    entries = paid_entries
    subtotal = 0
    if entries
      entries.each do |entry|
        subtotal += entry.subtotal
      end
    end
    return subtotal
  end

  def total_revenue
    subtotal = 0
    paid_amount = paid_revenue
    shipped_amount = shipped_revenue
    subtotal = paid_amount + shipped_amount
    return subtotal
  end

  def find_pending_order #synonymous to cart
    pending_orders = []
    self.orders.each do |order|
      if order.order_status == "pending"
        pending_orders << order
      end
    end

    if pending_orders.length > 1
      # some logic about combining the contents of the orders
    elsif pending_orders.length == 1
      return pending_orders.first
    else
      return false
    end
  end

  def has_products
    has_products = []
    User.all.each do |user|
      if user.products.length > 0
        has_products.push(user)
      end
    end
    return has_products
  end

  def show_available
    Product.where(visibility: true)
  end
end
