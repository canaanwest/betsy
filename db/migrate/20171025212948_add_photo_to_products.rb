class AddPhotoToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :product_photo, :string, :default => "http://fillmurray.com/g/300/300"
  end
end
