require 'rails_helper'

RSpec.describe SkateparksController do
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  let!(:skatepark) { create(:skatepark) }

  describe 'GET #index' do
    it 'returns a success response and assigns all skateparks' do
      get :index
      aggregate_failures do
        expect(response).to be_successful
        expect(assigns(:skateparks)).to include(skatepark)
      end
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: skatepark.id }
      aggregate_failures do
        expect(response).to be_successful
        expect(assigns(:skatepark)).to eq(skatepark)
      end
    end

    it 'sets meta tags' do
      get :show, params: { id: skatepark.id }
      aggregate_failures do
        expect(assigns(:title)).to eq("#{skatepark.name} | Skateparks.gr")
        expect(assigns(:meta_description)).to eq(skatepark.description.to_plain_text)
        expect(assigns(:meta_image)).to eq(url_for(skatepark.cover_image))
      end
    end

    it 'raises an error if the skatepark does not exist' do
      expect do
        get :show, params: { id: 'nonexistent-id' }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
