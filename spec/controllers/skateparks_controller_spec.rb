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

    context 'with published skateparks only' do
      let!(:published_skatepark) { create(:skatepark) }
      let!(:draft_skatepark) { create(:skatepark, :draft) }
      let!(:archived_skatepark) { create(:skatepark, :archived) }

      it 'shows only published skateparks' do
        get :index
        aggregate_failures do
          expect(assigns(:skateparks)).to include(published_skatepark)
          expect(assigns(:skateparks)).not_to include(draft_skatepark)
          expect(assigns(:skateparks)).not_to include(archived_skatepark)
        end
      end
    end

    context 'with country_code filter' do
      let!(:greece_skatepark) { create(:skatepark, country_code: 'GR') }
      let!(:us_skatepark) { create(:skatepark, :us_location) }

      it 'filters skateparks by country_code' do
        get :index, params: { country_code: 'US' }
        aggregate_failures do
          expect(assigns(:skateparks)).to include(us_skatepark)
          expect(assigns(:skateparks)).not_to include(greece_skatepark)
        end
      end
    end

    context 'with country_code and state filter' do
      let!(:california_skatepark) { create(:skatepark, country_code: 'US', state: 'CA') }
      let!(:texas_skatepark) { create(:skatepark, country_code: 'US', state: 'TX') }
      let!(:greece_skatepark) { create(:skatepark, country_code: 'GR') }

      it 'filters skateparks by country_code and state' do
        get :index, params: { country_code: 'US', state: 'CA' }
        aggregate_failures do
          expect(assigns(:skateparks)).to include(california_skatepark)
          expect(assigns(:skateparks)).not_to include(texas_skatepark)
          expect(assigns(:skateparks)).not_to include(greece_skatepark)
        end
      end

      it 'ignores state filter when country_code is missing' do
        get :index, params: { state: 'CA' }
        aggregate_failures do
          expect(assigns(:skateparks)).to include(california_skatepark)
          expect(assigns(:skateparks)).to include(texas_skatepark)
          expect(assigns(:skateparks)).to include(greece_skatepark)
        end
      end
    end

    context 'with no filters' do
      let!(:greece_park) { create(:skatepark) }
      let!(:us_park) { create(:skatepark, :us_location) }

      it 'returns all published skateparks' do
        get :index
        aggregate_failures do
          expect(assigns(:skateparks)).to include(greece_park)
          expect(assigns(:skateparks)).to include(us_park)
        end
      end
    end

    context 'pagination' do
      it 'accepts page parameter' do
        get :index, params: { page: 2 }
        expect(response).to be_successful
      end
    end

    context 'ordering' do
      before do
        create(:skatepark, name_en: 'Zebra Park', name_el: 'Zebra Park')
        create(:skatepark, name_en: 'Alpha Park', name_el: 'Alpha Park')
        create(:skatepark, name_en: 'Middle Park', name_el: 'Middle Park')
      end

      it 'returns skateparks in alphabetical order by name' do
        get :index
        names = assigns(:skateparks).map(&:name)
        expect(names).to eq(names.sort)
      end
    end

    context 'instance variables' do
      before do
        Rails.cache.clear
        create(:skatepark, country_code: 'GR')
      end

      it 'assigns @countries from cache' do
        get :index
        expect(assigns(:countries)).to be_an(Array)
        expect(assigns(:countries).first).to be_a(ISO3166::Country)
      end

      it 'assigns @states as empty when no country selected' do
        get :index
        expect(assigns(:states)).to eq([])
      end

      it 'assigns @states when country_code provided' do
        get :index, params: { country_code: 'GR' }
        expect(assigns(:states)).to be_an(Array)
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

  describe 'GET #available_states' do
    before do
      Rails.cache.clear
      create(:skatepark, country_code: 'US', state: 'CA')
      create(:skatepark, country_code: 'US', state: 'TX')
    end

    context 'with country_code parameter' do
      it 'returns states as JSON' do
        get :available_states, params: { country_code: 'US' }, format: :json
        aggregate_failures do
          expect(response).to be_successful
          expect(response.content_type).to match(%r{application/json})
          json_response = response.parsed_body
          expect(json_response).to be_an(Array)
          expect(json_response.map { |s| s['code'] }).to include('CA', 'TX')
        end
      end

      it 'returns states as turbo_stream' do
        get :available_states, params: { country_code: 'US' }, format: :turbo_stream
        aggregate_failures do
          expect(response).to be_successful
          expect(response.content_type).to match(%r{text/vnd\.turbo-stream\.html})
          expect(response.body).to include('turbo-stream')
          expect(response.body).to include('state_select')
        end
      end

      it 'filters states by selected country' do
        create(:skatepark, country_code: 'GR', state: 'I')
        get :available_states, params: { country_code: 'US' }, format: :json
        json_response = response.parsed_body
        aggregate_failures do
          expect(json_response.map { |s| s['code'] }).to include('CA', 'TX')
          expect(json_response.map { |s| s['code'] }).not_to include('I')
        end
      end
    end

    context 'without country_code parameter' do
      it 'returns empty array as JSON' do
        get :available_states, format: :json
        aggregate_failures do
          expect(response).to be_successful
          json_response = response.parsed_body
          expect(json_response).to eq([])
        end
      end

      it 'returns empty states in turbo_stream' do
        get :available_states, format: :turbo_stream
        expect(response).to be_successful
        expect(assigns(:states)).to eq([])
      end
    end
  end
end
