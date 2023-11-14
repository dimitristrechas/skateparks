require "application_system_test_case"

class SkateparksTest < ApplicationSystemTestCase
  setup do
    @skatepark = skateparks(:one)
  end

  test "visiting the index" do
    visit skateparks_url
    assert_selector "h1", text: "Skateparks"
  end

  test "should create skatepark" do
    visit skateparks_url
    click_on "New skatepark"

    fill_in "Lat", with: @skatepark.lat
    fill_in "Lng", with: @skatepark.lng
    fill_in "Name", with: @skatepark.name
    click_on "Create Skatepark"

    assert_text "Skatepark was successfully created"
    click_on "Back"
  end

  test "should update Skatepark" do
    visit skatepark_url(@skatepark)
    click_on "Edit this skatepark", match: :first

    fill_in "Lat", with: @skatepark.lat
    fill_in "Lng", with: @skatepark.lng
    fill_in "Name", with: @skatepark.name
    click_on "Update Skatepark"

    assert_text "Skatepark was successfully updated"
    click_on "Back"
  end

  test "should destroy Skatepark" do
    visit skatepark_url(@skatepark)
    click_on "Destroy this skatepark", match: :first

    assert_text "Skatepark was successfully destroyed"
  end
end
