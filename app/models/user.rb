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
    return false if !(entries)
    entries.each do |entry|
      paid_entries << entry if entry.paid?
    end
    return paid_entries if paid_entries.first != nil
    return false
  end

  def shipped_entries
    entries = self.merchant_entries
    shipped_entries = []
    return false if !(entries)
    entries.each do |entry|
      shipped_entries << entry if entry.shipped?
    end
    return shipped_entries if shipped_entries.first != nil
    return false
  end

  def canceled_entries
    entries = self.merchant_entries
    canceled_entries = []
    return false if !(entries)
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

    #TODO- Question from Julia- Why would a user have multiple pending orders? If they sign in as a user and add to cart, and then logout and add some to a new cart, then sign back in?
    if pending_orders.length > 0
      return pending_orders.first
    else
      return false
    end
  end

  #TODO-Question from Julia- I think we can remove this method. It is not referenced anywhere in the project.
  # def has_products
  #   has_products = []
  #   User.all.each do |user|
  #     if user.products.length > 0
  #       has_products.push(user)
  #     end
  #   end
  #   return has_products
  # end

  #TODO- Question from Julia- This method is shown in two places: here and in the application model. I think we can remove it here.
  def show_available
    Product.where(visibility: true)
   end
end
