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
  # CW wants to keep
  def show_available
    Product.where(visibility: true)
  end

  def has_past_orders?
    past_orders = []
    self.orders.each do |order|
      if order.order_status == "paid" || order.order_status == "shipped" || order.order_status == "canceled"
        past_orders << order
      end
    end
    if past_orders.length >= 1
      return true
    else
      return false
    end
  end
end
