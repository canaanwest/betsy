require "test_helper"

describe OrderProductsController do
  # let(:entry) = {order_products(:mias_pending_products) }
  describe "destroy" do
    it "should succeeed for an extant Order Product" do
      user = users(:mia)
      log_in(user, :github)
      get root_path
      get cart_path
      entry = order_products(:mias_pending_products).id
      delete order_product_path(entry)
      must_respond_with :redirect
    end
  describe "ship" do
    it "should return 404 if entry does not exist" do

      post ship_path(100000)
      must_respond_with :not_found
    end
    it "should return 404 if the items for that entry are already shipped" do
      shipped_order = orders(:shipped_order)
      product = products(:chocolate)
      one_single_chocolate = Item.new
      one_single_chocolate.order = shipped_order
      one_single_chocolate.product = product
      one_single_chocolate.shipping_status = true
      one_single_chocolate.save
      entry = OrderProduct.new
      entry.product = product
      entry.order = shipped_order
      entry.quantity = 1
      entry.save
      # binding.pry
      post ship_path(entry.id)
      must_respond_with :not_found
    end
    it "should redirect to order_fulfillment if successful" do
      shipped_order = orders(:shipped_order)
      product = products(:chocolate)
      one_single_chocolate = Item.new
      one_single_chocolate.order = shipped_order
      one_single_chocolate.product = product
      one_single_chocolate.save
      entry = OrderProduct.new
      entry.product = product
      entry.order = shipped_order
      entry.quantity = 1
      entry.save

      post ship_path(entry.id)
      must_respond_with :redirect
    end

    it "should respond with success if items get shipped" do
      shipped_order = orders(:shipped_order)
      product = products(:chocolate)
      one_single_chocolate = Item.new
      one_single_chocolate.order = shipped_order
      one_single_chocolate.product = product
      one_single_chocolate.save
      entry = OrderProduct.new
      entry.product = product
      entry.order = shipped_order
      entry.quantity = 1
      entry.save

      post ship_path(entry.id)
      assert_redirected_to order_fulfillment_path
    end
  end


  end
end
