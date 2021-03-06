
require "test_helper"
require "pry"

describe Order do
  let(:order) { Order.new }
  let(:order2) { Order.new }
  let(:order3) { Order.new }
  let(:pending_order) { orders(:pending_order)}
  let(:paid_order)  { orders(:paid_order) }
  let(:shipped_order) { orders(:shipped_order)}
  let(:canceled_order) { orders(:canceled_order)}
  let(:guest_pending_order) { orders(:guest_pending_order)}

  describe "relations" do
    it "has a nil user if not logged in" do
      result = guest_pending_order.user
      result.must_be :==, nil

    end

    it "has a user if authenticated user is logged in" do
      result = pending_order.user
      result.must_be_instance_of User

    end

    it "has a billing datum if paid, shipped or canceled" do
      # binding.pry
      order.session_id = "test session"
      order.order_status = "paid"
      (order.valid?).must_equal false
      order.errors.must_include :billing_datum_id
      order.errors[:billing_datum_id].must_equal ["is missing.  Please entire valid billing information."]
      order.billing_datum_id = billing_data(:guest_billing_datum).id
      (order.valid?).must_equal true
      order.billing_datum.must_be_instance_of BillingDatum


    end

    it "does not need to have billing data if pending" do
      order.order_status.must_equal "pending"
      order.billing_datum.must_be :==, nil
      order.session_id = "fake session"
      order.valid?.must_equal true

    end
    it "should have a collection of order_products" do
      # binding.pry
      order.order_products.length.must_equal 0
      paid_order.order_products.length.must_be :>, 0
      paid_order.order_products.each do |entry|
        entry.must_be_instance_of OrderProduct
      end
      guest_pending_order.order_products.length.must_be :>, 0
      guest_pending_order.order_products.each do |entry|
        entry.must_be_instance_of OrderProduct
      end
    end
  end



  describe "validations" do
    it "must have session_id" do
      order.session_id.must_be :==, nil
      order.valid?.must_equal false
    end


    it "must have an order order_status of pending, paid, shipped or canceled" do
      orders.each do |test_order|
        ["pending","paid", "shipped", "canceled"].must_include test_order.order_status
        test_order.valid?.must_equal true
        test_order.order_status = nil
        test_order.valid?.must_equal false
        test_order.errors.must_include :order_status
        #not sure what message would be
        # test_order.errors[:order_status].must_equal "something"
        test_order.order_status = ""
        test_order.valid?.must_equal false
        test_order.order_status = 39085
        test_order.valid?.must_equal false
        test_order.order_status = "pending"
        test_order.valid?.must_equal true
      end


    end


    it "new orders should have order_status of pending" do
      order.order_status.must_equal "pending"
      another_order = Order.new
      another_order.order_status.must_equal "pending"
    end


    it "must have a user if authenticated user is logged in" do
      #TODO: maybe this should be in the controller instead?

    end

    it "must have an associated billing datum if paid, shipped or canceled" do
      order.session_id = "test session"
      ["paid", "shipped", "canceled"].each do |test_order_status|
        order.order_status = test_order_status
        order.valid?.must_equal false
        # binding.pry
        order.billing_datum = billing_data(:guest_billing_datum)
        order.valid?.must_equal true
        order.billing_datum = nil
      end

    end

  end

  describe "model methods" do
    describe "sub_total, tax_amount and taxed_total methods" do
      it "returns a number value" do
        orders(:unshipped_paid_order).sub_total.must_be_instance_of BigDecimal
        orders(:unshipped_paid_order).taxed_total.must_be_instance_of BigDecimal
      end

      it "correctly calculates the cost of all items in an order" do
        #order_products: shipped_lamp and shipped pencil
        orders(:unshipped_paid_order).sub_total.must_equal 605
      end

      it "correctly calculates the cost of all items in an order WITH TAX!" do
        #order_products: shipped_lamp and shipped pencil
        orders(:unshipped_paid_order).taxed_total.must_equal 658.6635
      end
    end

    describe "has_invalid_entries?" do
      it "returns false if it has only valid entries (i.e. order_products) and true if has invalid entries" do
        order = orders(:unshipped_paid_order)
        order.has_invalid_entries?.must_equal false
        # binding.pry
        items = order.order_products.first.product.items
        items.first.shipping_status = "true"
        order.has_invalid_entries?.must_equal true
      end
    end

    describe "check_for_duplicates" do
      it "returns a order_product object if there is an entry in the cart with the same user_id. otherwise it returns false" do
        orders(:one).check_for_duplicates(products(:converse).id).must_be_instance_of OrderProduct
        pencil_order = orders(:guest_pending_order)
        result = pencil_order.check_for_duplicates(products(:converse).id)
        result.must_equal false
      end


    end

  end



end
