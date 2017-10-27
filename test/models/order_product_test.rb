require "test_helper"

describe OrderProduct do
  let(:order_product) { OrderProduct.new }

  describe "validations" do
    it "requires an order_id, product_id, quantity and items_available to be valid" do
      entry = OrderProduct.find_by(id: order_products(:two).id)
      entry.valid?.must_equal true
    end
  end

  describe "relations" do

  end

  # describe "paid?" do
    # it "returns true for paid orders and false for unpaid orders" do
    #   orders(:pending_order).paid?.must_equal false
    #   orders(:pending_order).order_status = "paid"
    #   orders(:pending_order).paid?.must_equal true
    # end
  # end


  describe "items_available?" do
    it "should return true if product has available inventory" do
      entry = OrderProduct.find_by(id: order_products(:mias_pending_products).id)
      result = entry.items_available?
      result.must_equal true
    end

    it "should return false if product is out of stock" do
      entry = OrderProduct.find_by(id: order_products(:guest_pending_products).id)
      result = entry.items_available?
      result.must_equal true
      entry.product.items.first.shipping_status = "true"
      entry.items_available?.must_equal false

    end
  end

  describe "pending?" do
    it "should return true if it's order is pending" do
      entry = order_products(:mias_pending_products)
      result = entry.pending?
      result.must_equal true
    end

    it "should return false if it's order is not pending" do
      entry = order_products(:pencil_paid_order)
      order = entry.order
      order.must_equal orders(:paid_order)
      result = entry.pending?
      # binding.pry
      result.must_equal false
    end
  end

  describe "paid?" do
    it "should return true if it's order is paid" do
      entry = order_products(:three)
      entry.order_id.must_equal orders(:two).id
      result = entry.paid?
      result.must_equal true
    end

    it "should return false if it's order is not paid" do
      entry = order_products(:mias_pending_products)
      order = entry.order
      order.must_equal orders(:mias_pending_order)
      result = entry.paid?
      # binding.pry
      result.must_equal false
    end
  end

  describe "canceled?" do
    it "should return true if it's order is canceled" do
      entry = order_products(:two)
      entry.order_id.must_equal orders(:four).id
      result = entry.canceled?
      result.must_equal true
    end

    it "should return false if it's order is not canceled" do
      entry = order_products(:mias_pending_products)
      order = entry.order
      order.must_equal orders(:mias_pending_order)
      result = entry.canceled?
      # binding.pry
      result.must_equal false
    end
  end

  describe "shipped?" do
    it "should return true if it's order is shipped" do
      entry = order_products(:shipped_order_product)
      entry.order_id.must_equal orders(:three).id
      result = entry.shipped?
      result.must_equal true
    end

    it "should return false if it's order is not shipped" do
      entry = order_products(:mias_pending_products)
      order = entry.order
      order.must_equal orders(:mias_pending_order)
      result = entry.shipped?
      # binding.pry
      result.must_equal false
    end
  end

  describe "items_shipped?" do
    it "returns true if all order_products in an order have been shipped" do
      order_products(:three).items_shipped?.must_equal true

    end

    it "returns false if not all order_products in an order have not been shipped" do
      order_products(:shipped_lamp).items_shipped?.must_equal false
    end
  end

  describe "subtotal" do
    it "should return a number" do
      order_products(:one).subtotal.must_be_instance_of BigDecimal
    end

    it "should return the correct subtotal" do
      order_products(:one).subtotal.must_equal order_products(:one).quantity * order_products(:one).product.price
    end

    it "should return false if missing a quantity or price" do
      # order_products(:one).quantity = 0
      # order_products(:one).subtotal.must_equal false
    end
  end



end
