require "test_helper"

class SkateparksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @skatepark = skateparks(:one)
  end

  test "should get index" do
    get skateparks_url
    assert_response :success
  end

  test "should show skatepark" do
    get skatepark_url(@skatepark)
    assert_response :success
  end
end
