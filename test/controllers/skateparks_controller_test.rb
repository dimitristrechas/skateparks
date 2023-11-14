require "test_helper"

class SkateparksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @skatepark = skateparks(:one)
  end

  test "should get index" do
    get skateparks_url
    assert_response :success
  end

  test "should get new" do
    get new_skatepark_url
    assert_response :success
  end

  test "should create skatepark" do
    assert_difference("Skatepark.count") do
      post skateparks_url, params: { skatepark: { lat: @skatepark.lat, lng: @skatepark.lng, name: @skatepark.name } }
    end

    assert_redirected_to skatepark_url(Skatepark.last)
  end

  test "should show skatepark" do
    get skatepark_url(@skatepark)
    assert_response :success
  end

  test "should get edit" do
    get edit_skatepark_url(@skatepark)
    assert_response :success
  end

  test "should update skatepark" do
    patch skatepark_url(@skatepark), params: { skatepark: { lat: @skatepark.lat, lng: @skatepark.lng, name: @skatepark.name } }
    assert_redirected_to skatepark_url(@skatepark)
  end

  test "should destroy skatepark" do
    assert_difference("Skatepark.count", -1) do
      delete skatepark_url(@skatepark)
    end

    assert_redirected_to skateparks_url
  end
end
