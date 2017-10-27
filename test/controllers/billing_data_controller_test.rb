require 'test_helper'

#IF IT'S COMMENTED OUT, IT'S GOT ERRORS
describe BillingDataController do
  describe "Index" do
    it "should not show a list of all billing data" do
      get billing_data_path
      must_respond_with :not_found
    end
  end

  describe "creating new billing information" do
    it "it should produce a form for entering payment information" do
      get new_billing_datum_path
      must_respond_with :success
    end

    it "should create new billing information with valid information" do
      billing_data = {
        billing_datum: {
          email: "test@testdata.com",
          mailing_address: "2200 New Street, Seattle, WA, 09020",
          credit_card_name: "test card",
          credit_card_number: "4332 2321 1213 1241",
          credit_card_cvv: "333",
          billing_zip_code: "09020",
          expiration_date: "121"
        }
      }
      proc {post billing_data_path, params: billing_data}.must_change 'BillingDatum.count', 1

      must_respond_with :redirect
    end

    it "should not create new billing information when valid data isn't present" do
      billing_data = {
        billing_datum: {
          email: "test@testdata.com",
          mailing_address: "2200 New Street, Seattle, WA, 09020",
          credit_card_name: "test card",
          credit_card_number: "4332 2321 1213 1241",
          credit_card_cvv: "333",
          billing_zip_code: "09020",
          expiration_date: "211"
        }
      }

      billing_data.each do |key, value|
        billing_data[key] = nil

        proc {post billing_data_path, params: billing_data}.must_change 'BillingDatum.count', 0
        must_respond_with :bad_request
      end
    end
  end

  it "!!!should produce an edit form for billing data" do
    #issue connecting user to data
    log_in(users(:carl), :github)
    session[:user_id].must_equal users(:carl).id

    get edit_billing_datum_path(billing_data(:carl_billing_datum))
    must_respond_with :success
  end

  it "should update billing information" do
    person_data = billing_data(:carl_billing_datum)
    user = User.find_by(id: person_data.user_id)
    log_in( user, :github)


    billing_data = {
      billing_datum: {
        email: "test@testdata.com",
        mailing_address: "2200 New Street, Seattle, WA, 09020",
        credit_card_name: "test card",
        credit_card_number: "4332 2321 1213 1241",
        credit_card_cvv: "333",
        billing_zip_code: "09020",
        expiration_date: "121"
      }
    }

    session[:user_id].must_equal User.users(:carl).id
    session[:user_id].must_equal BillingDatum.find_by(id: billing_data(:carl_billing_datum)).user_id

    put billing_datum_path(person_data), params: billing_data
    must_respond_with :redirect


    must_redirect_to billing_info_path(billing_data(:carl_billing_datum))
    # should redirect to the "show billing info/confirm purchase"
  end

  describe "#SHOW" do
    it "shows a logged in user her billing information" do
      log_in(users(:carl), :github)
      #there is a problem with the connection between user and user id
      get billing_datum_path(billing_data(:carl_billing_datum).id)
      must_respond_with :success
    end

    it "does not show billing information to anyone not tied to it through a product" do
      get billing_data_path(billing_data(:carl_billing_datum).id)
      must_respond_with :not_found
    end

    it "doesn't show billing data that doesn't exist" do

      get billing_datum_path(BillingDatum.last.id+1)
      must_redirect_to root_path
    end
  end
end
