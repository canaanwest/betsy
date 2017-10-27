class ItemsController < ApplicationController
  def index
    @item = Item.order(:id)
  end


  def show
    @item = Item.find_by(id: params[:id])
    puts params[:id]

    # render_404 unless @item

    unless @item
      flash[:error] = "Item not found"
      redirect_to root_path
    end
  end

  def new
    @item = Item.new
  end

  def create
    # if !(Product.find_by(id: params[:id]))
    #   render_404
    #   return
    # end
    @item = Item.new(product_id: params[:id])
    # binding.pry

    if @item.save
      # puts "success"
      flash[:success] = "#{Product.find(params[:id]).name} item added successfully"
      redirect_back(fallback_location: root_path)
    else
      # puts "fail"
      # puts @item.errors.messages
      flash.now[:error] = "Item not added to Product # #{params[:id]}"
      redirect_to profile_path, status: 400
    end
  end

  def destroy

    if Item.where(product_id: params[:id]).length > 0
      @item = Item.where(product_id: params[:id])
      @item.last.destroy
      redirect_back(fallback_location: root_path)

      flash[:result_text] = "1 #{Product.find(params[:id]).name} removed from inventory!"

    else
      flash[:result_text] = "There are no more items to remove"
      redirect_to profile_path, status: 400
    end
  end

  private
  # GM: This never gets called in this controller
  # def item_params
  #   return params.require(:items).permit(:shipping_status, :purchase_status, :product_id, :order_id)
  # end

end
