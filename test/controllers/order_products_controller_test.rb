require "test_helper"

describe OrderProductsController do
  # let(:entry) = {order_products(:mias_pending_products) }
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

    it "should redirect to order fulfillment path if shipping an order without items" do
      entry = order_products(:entry_without_items)

      post ship_path(entry.id)
      must_respond_with :redirect
      flash[:result_text].must_equal "There was an error with updating entry #{entry.id}.  There are no items associated with this order.  Sorry."
    end

  end
  # describe "create" do
  #   # i think we never use this lol
  #   it "creates an orderproduct with valid data for an order" do
  #     product = products(:converse)
  #     get root_path
  #     start_count = OrderProduct.count
  #     get product_path(product.id)
  #     # order = orders(:mias_pending_order)
  #     # entry_data = {
  #     #   id:
  #     #   }
  #     # }
  #     # start_count = OrderProduct.count
  #
  #     post order_products_path
  #     must_respond_with :redirect
  #
  #     OrderProduct.count.must_equal start_count + 1
  #   end
  # end

  describe "update" do
    it "succeeds for valid data and an existing order id" do
      entry = order_products(:existing_tea_entry)
      # first_quantity = entry.quantity
      entry_data = {
        order_product: {
          quantity: 2
        }
      }

      patch order_product_path(entry.id), params: entry_data
      must_redirect_to cart_path

      # Verify the DB was really modified
      OrderProduct.find(entry.id).quantity.must_equal entry_data[:order_product][:quantity]
    end

    it "should render 404 for fake entry" do
      patch order_product_path("fake_entry")
      must_respond_with :not_found
    end

    it "shouldn't accept strings as input" do
      entry = order_products(:existing_tea_entry)
      # first_quantity = entry.quantity
      entry_data = {
        order_product: {
          quantity: "hey what is this"
        }
      }

      patch order_product_path(entry.id), params: entry_data
      flash[:result_text].must_equal "Could not update #{entry.product.name}.  Make sure you are entering a number greater than 0.  If you wanted to delete it, click delete from cart."
      must_respond_with :bad_request
    end

    it "shouldn't accept 0 as input" do
      entry = order_products(:existing_tea_entry)
      # first_quantity = entry.quantity
      entry_data = {
        order_product: {
          quantity: 0
        }
      }

      patch order_product_path(entry.id), params: entry_data
      flash[:result_text].must_equal "Could not update #{entry.product.name}.  Make sure you are entering a number greater than 0.  If you wanted to delete it, click delete from cart."
      must_respond_with :bad_request
    end
  end
  describe "destroy" do
    it "AuthUser: should succeed for an extant Order Product" do
      user = users(:mia)
      log_in(user, :github)
      get root_path
      get cart_path
      entry = order_products(:mias_pending_products).id
      delete order_product_path(entry)
      must_respond_with :redirect
    end
    it "should succeed for an existant orderproduct" do
      entry = order_products(:existing_tea_entry)

      delete order_product_path(entry.id)
      must_redirect_to cart_path

      OrderProduct.find_by(id: entry.id).must_be_nil

    end

    it "should render 404 and not update the database for fake orderproduct" do
      start_count = OrderProduct.count

      delete order_product_path("fake thing")
      delete order_product_path(938408)

      must_respond_with :not_found
      OrderProduct.count.must_equal start_count
    end
  end

end
