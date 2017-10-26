class AddPhotoToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :product_photo, :string, :default => "https://i.imgur.com/M8g4Cdu.jpg?1"
  end
end
