require 'rails_helper'

RSpec.describe SkateparksController, type: :controller do
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  let(:valid_skatepark_attributes) do
    {
      name: "Test Skatepark",
      lat: 12.345,
      lng: 67.890,
      description: "<strong>A great skatepark for everyone!</strong>",
      cover_image: fixture_file_upload('sample_image2.jpg'),
      images: [
        fixture_file_upload('sample_image1.jpg'),
        fixture_file_upload('sample_image3.jpg')
      ],
      status: :published
    }
  end

  let!(:skatepark) { Skatepark.create!(valid_skatepark_attributes) }

  describe "GET #index" do
    it "returns a success response and assigns all skateparks" do
      get :index
      expect(response).to be_successful
      expect(assigns(:skateparks)).to include(skatepark)
    end
  end

  describe "GET #show" do
    it "returns a success response and assigns the requested skatepark" do
      get :show, params: { id: skatepark.id }
      expect(response).to be_successful
      expect(assigns(:skatepark)).to eq(skatepark)
      expect(assigns(:title)).to eq("#{skatepark.name} | Skateparks.gr")
      expect(assigns(:meta_description)).to eq(skatepark.description.to_plain_text)
      expect(assigns(:meta_image)).to eq(url_for(skatepark.cover_image))
    end

    it "raises an error if the skatepark does not exist" do
      expect {
        get :show, params: { id: "nonexistent-id" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
