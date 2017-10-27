require "test_helper"

describe Category do

  describe "validation" do
    it "should be valid" do
      categories(:clothes).must_be :valid?
    end

    it "should have a unique name" do
      categories(:clothes).must_be :valid?
      new_clothes = Category.new
      new_clothes.name = "clothes"
      new_clothes.save
      new_clothes.valid?.must_equal false
    end
  end

end
