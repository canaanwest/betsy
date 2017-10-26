class BillingDataController < ApplicationController
  before_action :find_billing, only: [:permission, :edit, :update, :show]
  before_action :permission, only: [:edit, :update, :show]


  def index
    render render_404
  end

  def show
    unless @billing_data
      flash[:error] = "Billing data not found"
      redirect_to root_path
    end
  end

  def edit
    @billing_data = BillingDatum.find_by(id: params[:id].to_i)
    unless @billing_data
      redirect_to root_path
    end
  end

  def update
    if @billing_data.update_attributes billing_data_params
      redirect_to billing_datum_path(@billing_data.id)
      @billing_data.user = @user
    else
      flash[:result_text] = "Didn't save. Make sure your fields are complete!"
      render :edit
    end
  end

  def new
    @user = session[:user_id]
    @billing_data = BillingDatum.new

  end

  def create
    @billing_data = BillingDatum.new billing_data_params
    @billing_data.user = @user
    if @billing_data.save
      flash[:result_text] = "Does this look right?"
      redirect_to billing_datum_path(@billing_data.id)
      save_billing(@billing_data.id)
    else
      flash.now[:error] = "Could not create Billing Data"
      render :new
    end
  end

  private
  def find_billing
    @billing_data = BillingDatum.find_by(id: params[:id].to_i)
  end

  def save_billing(id)
    @user = session[:user_id]
    if @user
      user = User.find_by(id: @user)
      user.billing_datum_id = id
      user.save
    end

    @pending_order.billing_datum_id = id
    @pending_order.save
  end

  def billing_data_params
    return params.require(:billing_datum).permit(:email, :mailing_address, :credit_card_name, :credit_card_number, :credit_card_cvv, :billing_zip_code, :expiration_date)
  end

  def permission
    unless session[:user_id] == @billing_data.user_id || @pending_order.billing_datum_id == @billing_data.id
      render render_404
    end
  end

end
