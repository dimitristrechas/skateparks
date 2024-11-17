require 'rails_helper'

RSpec.describe Admin::SkateparksController, type: :controller do
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  let(:valid_attributes) do
    {
      name_el: "Test Skatepark",
      name_en: "Test Skatepark",
      lat: 12.345,
      lng: 67.890,
      description_el: "<strong>A great skatepark for everyone!</strong>",
      description_en: "<strong>A great skatepark for everyone!</strong>",
      cover_image: fixture_file_upload('sample_image2.jpg'),
      images: [
        fixture_file_upload('sample_image1.jpg'),
        fixture_file_upload('sample_image3.jpg')
      ],
      status: :published
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      lat: nil,
      lng: nil,
      description: nil,
      cover_image: nil,
      images: [],
      status: nil
    }
  end

  let!(:skatepark) { Skatepark.create!(valid_attributes) }

  before do
    allow(controller).to receive(:http_basic_authenticate_or_request_with)
                     .with(anything).and_return true
  end

  describe "GET #index" do
    it "returns a success response and assigns all skateparks" do
      get :index
      expect(response).to be_successful
      expect(assigns(:skateparks)).to include(skatepark)
    end
  end

  describe "GET #show" do
    it "returns a success response and assigns the requested skatepark" do
      get :show, params: { id: skatepark.to_param }
      expect(response).to be_successful
      expect(assigns(:skatepark)).to eq(skatepark)
    end
  end

  describe "GET #new" do
    it "returns a success response and assigns a new skatepark" do
      get :new
      expect(response).to be_successful
      expect(assigns(:skatepark)).to be_a_new(Skatepark)
    end
  end

  describe "GET #edit" do
    it "returns a success response and assigns the requested skatepark" do
      get :edit, params: { id: skatepark.to_param }
      expect(response).to be_successful
      expect(assigns(:skatepark)).to eq(skatepark)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new Skatepark" do
        expect {
          post :create, params: { skatepark: valid_attributes }
        }.to change(Skatepark, :count).by(1)
      end

      it "redirects to the created skatepark" do
        post :create, params: { skatepark: valid_attributes }
        expect(response).to redirect_to(admin_skatepark_url(Skatepark.last))
        # expect(response).to have_http_status(422)
        
      end
    end

    context "with invalid parameters" do
      it "does not create a new Skatepark" do
        expect {
          post :create, params: { skatepark: invalid_attributes }
        }.to change(Skatepark, :count).by(0)
      end

      it "renders the new template" do
        post :create, params: { skatepark: invalid_attributes }
        expect(response).to render_template("new")
      end
    end
  end

  describe "PATCH/PUT #update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          name_el: "Updated Skatepark",
          lat: 23.456,
          lng: 78.901,
          description_el: "<strong>An updated description</strong>"
        }
      end

      it "updates the requested skatepark" do
        patch :update, params: { id: skatepark.to_param, skatepark: new_attributes }
        skatepark.reload
        expect(skatepark.name).to eq("Updated Skatepark")
        expect(skatepark.lat).to eq(23.456)
        expect(skatepark.lng).to eq(78.901)
        expect(skatepark.description_el.to_plain_text).to eq("An updated description")
      end

      it "redirects to the skatepark" do
        patch :update, params: { id: skatepark.to_param, skatepark: new_attributes }
        expect(response).to redirect_to(admin_skatepark_url(skatepark))
      end
    end

    context "with invalid parameters" do
      it "renders the edit template" do
        patch :update, params: { id: skatepark.to_param, skatepark: invalid_attributes }
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested skatepark" do
      expect {
        delete :destroy, params: { id: skatepark.to_param }
      }.to change(Skatepark, :count).by(-1)
    end

    it "redirects to the skateparks list" do
      delete :destroy, params: { id: skatepark.to_param }
      expect(response).to redirect_to(admin_skateparks_url)
    end
  end
end