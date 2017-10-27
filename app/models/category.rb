class Category < ApplicationRecord
  # add through: to associate join table
  has_and_belongs_to_many :products, through: :categories_products
  validates :name, presence: true
  validates :name, uniqueness: true

  # before_validation :fix_category


  # private
  # def fix_category
  #   if self.category
  #     self.category = self.category.downcase.singularize
  #   end
  # end

  #TODO Julia removed the below method because it is a duplicate of a method in the product class (where it belongs)
  # def show_available
  #   Product.where(visibility: true)
  # end
end
