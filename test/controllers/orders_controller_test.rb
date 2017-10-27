require "test_helper"

describe OrdersController do
  describe "view" do
  it "should successfully let an auth user to view billing data info for an order" do
    user = users(:carl)
    log_in(user, :github)
    pending_order = orders(:mias_pending_order)
    get view_order_path(pending_order.id)
    must_respond_with :success
  end

  it "should render 404 for a guest" do
    pending_order = orders(:mias_pending_order)
    get root_path
    get view_order_path(pending_order.id)
    must_respond_with :not_found
  end
  it "should render 404 for a user without access" do
    user = users(:no_access)
    log_in(user, :github)
    pending_order = orders(:mias_pending_order)
    get root_path
    # binding.pry
    get view_order_path(pending_order.id)
    must_respond_with :not_found
  end
  end
  describe "show" do
    # GM: how to test instance variables ?? )-':
    it "should find cart" do
      user = users(:mia)
      log_in(user, :github)
      get cart_path
      # assigns(:cart)
      # assigns(:cart).must_equal orders(:mias_pending_order)
      must_respond_with :success
    end
  end
  describe "checkout" do
    it "should be successful with a valid order" do
      user = users(:mia)
      log_in(user, :github)
      get root_path
      session[:pending_order_id].must_equal orders(:mias_pending_order).id
      get checkout_path
      must_respond_with :success
    end

    it "should change available_items for a product" do
      user = users(:mia)
      log_in(user, :github)
      get root_path
      session[:pending_order_id].must_equal orders(:mias_pending_order).id
      order = Order.find(session[:pending_order_id])
      previous = products(:converse).num_available

      get checkout_path

      result = Product.find(products(:converse).id).num_available
      # binding.pry
      result.must_equal (previous - 1)


    end
  end



  # it "should post to add_product" do
  #   product = products(:converse)
  #   # user = users(:mia)
  #   # log_in(user, :github)
  #   proc {
  #     post add_product_path(product.id)
  #   }.must_change 'OrderProduct.count', 0
  #   must_respond_with :redirect
  #   must_redirect_to root_path
  #   flash[:result_text].must_equal  "Could not add that product to your cart"
  #
  #
  # end
  # it "should get show" do
  #   get orders_show_url
  #   value(response).must_be :success?
  # end
  #
  # it "should get edit" do
  #   get orders_edit_url
  #   value(response).must_be :success?
  # end
  #
  # it "should get update" do
  #   get orders_update_url
  #   value(response).must_be :success?
  # end
  #
  # it "should get new" do
  #   get orders_new_url
  #   value(response).must_be :success?
  # end
  #
  # it "should get create" do
  #   get orders_create_url
  #   value(response).must_be :success?
  # end
  #
  # it "should get destroy" do
  #   get orders_destroy_url
  #   value(response).must_be :success?
  # end

end
