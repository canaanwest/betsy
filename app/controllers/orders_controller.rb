class OrdersController < ApplicationController
  before_action :permission, except: [:show]
  before_action :view_order_permission, only: [:view]

  def view
    find_order
  end


  def show
    @cart = @pending_order
  end


  def checkout
    if mark_items_as_purchased
      @cart = @pending_order
      flash[:status] = :success
      @pending_order.order_status = "paid"
      @pending_order.save
      session[:pending_order_id] = nil
      find_cart

      # if @user
      #   Order.where(user_id =).last = "paid"
      #   @user.save
      # end
      #nexT: mark the entire order as paid (currently only items are marked paid)
    else
      flash[:status] = :error
      flash[:result_text] = "There was an error; you could not be checked out at this time"
      redirect_to cart_path, status: 400
    end
  end



  # def add_product
  #   @cart_entry = OrderProduct.new(product_id: params[:id].to_i, order_id: @pending_order.id)
  #   if @cart_entry.save
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully added to your cart!"
  #     redirect_to order_path(@pending_order)
  #     redirect_to product_path(params[:id])
  #   else
  #     flash[:result_text] = "Could not add that product to your cart"
  #     flash[:messages] = @cart_entry.errors
  #     redirect_to root_path
  #   end
  # end


  private
  def cart_entry_params
    # params.require(:product).permit(:id, :name, :description, :price, :user)
  end

  def mark_items_as_purchased
    entries = @pending_order.order_products
    order_id = @pending_order.id
    @items_for_purchase = []

    entries.each do |entry|
      if !(entry.valid?)
        flash[:status] = :error
        flash[:result_text] = "Check your cart, inventory has changed for #{entry.product}"
        flash[:messages] = entry.errors
        return false
      end
      quantity = entry.quantity
      available_items = entry.product.available_items

      quantity.times do
        @items_for_purchase << available_items.pop
      end
    end

    @items_for_purchase.each {|item| item.purchase(order_id)}


    @items_for_purchase.each do |item|

      if item.save
        flash[:result_text] = "Items were saved."
      else
        flash[:status] = :error
        flash[:result_text] << "Items were not saved.  Please contact web administrator.   "
        flash[:messages] = "There were errors"
        # item.errors
        # redirect_to cart_path
        return
      end

    end
  end

  def find_order
    # binding.pry
    @order_for_view = Order.find(params[:id].to_i)
    # binding.pry
  end


  def permission
    unless @user
      render_404
    end
  end

  def view_order_permission
    @order_for_view = Order.find(params[:id].to_i)
    if @order_for_view
      products = @order_for_view.order_products.map {|entry| entry.product}
      # binding.pry
      owners_of_products = []
      products.each {|product| owners_of_products << product.user_id}
      if !(owners_of_products.include? @user.id)
        render_404
        # return
      end
    end
  end
end
