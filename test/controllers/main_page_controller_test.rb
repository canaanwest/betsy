require "test_helper"

describe MainPageController do
  it "should get index" do
    get main_pages_path
    must_respond_with :success
  end

end
