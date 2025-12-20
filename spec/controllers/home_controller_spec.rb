require 'rails_helper'

RSpec.describe HomeController do
  let!(:published_skatepark) { create(:skatepark) }

  describe 'GET #index' do
    before do
      Rails.cache.clear
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns only published skateparks to @skateparks' do
      get :index
      expect(assigns(:skateparks)).to eq([published_skatepark])
    end

    it 'orders @skateparks by created_at desc' do
      older_skatepark = create(:skatepark)
      older_skatepark.update_column(:created_at, 2.days.ago) # rubocop:disable Rails/SkipsModelValidations
      newer_skatepark = create(:skatepark)
      newer_skatepark.update_column(:created_at, 1.day.ago) # rubocop:disable Rails/SkipsModelValidations

      get :index

      expect(assigns(:skateparks)).to eq([published_skatepark, newer_skatepark, older_skatepark])
    end

    it 'assigns the locale from params to @locale' do
      get :index, params: { locale: 'el' }
      expect(assigns(:locale)).to eq('el')
    end

    context 'with latest skateparks' do
      it 'assigns @skateparks_latest from cache' do
        allow(Skatepark).to receive(:latest).and_call_original

        get :index

        expect(assigns(:skateparks_latest)).to be_an(Array)
        expect(Skatepark).to have_received(:latest)
      end

      it 'caches @skateparks_latest with key skateparks_latest' do
        get :index

        cached_value = Rails.cache.read('skateparks_latest')
        expect(cached_value).to eq(assigns(:skateparks_latest))
      end

      it 'uses cached value on subsequent requests' do
        get :index
        allow(Skatepark).to receive(:latest)

        get :index

        expect(Skatepark).not_to have_received(:latest)
      end
    end

    context 'with popular skateparks' do
      before do
        create(:popular_skatepark, skatepark: published_skatepark)
      end

      it 'assigns @skateparks_popular from cache' do
        allow(Skatepark).to receive(:popular).and_call_original

        get :index

        expect(assigns(:skateparks_popular)).to be_an(Array)
        expect(Skatepark).to have_received(:popular)
      end

      it 'caches @skateparks_popular with key skateparks_popular' do
        get :index

        cached_value = Rails.cache.read('skateparks_popular')
        expect(cached_value).to eq(assigns(:skateparks_popular))
      end

      it 'uses cached value on subsequent requests' do
        get :index
        allow(Skatepark).to receive(:popular)

        get :index

        expect(Skatepark).not_to have_received(:popular)
      end
    end
  end

  describe 'GET #about' do
    it 'returns a success response' do
      get :about
      expect(response).to be_successful
    end

    it 'assigns the title and meta_description' do
      get :about
      expect(assigns(:title)).to eq(I18n.t('about'))
      expect(assigns(:meta_description)).to eq(I18n.t('about_details'))
    end
  end

  describe 'GET #contact' do
    it 'returns a success response' do
      get :contact
      expect(response).to be_successful
    end

    it 'assigns the title and meta_description' do
      get :contact
      expect(assigns(:title)).to eq(I18n.t('contact'))
      expect(assigns(:meta_description)).to eq(I18n.t('contact_details'))
    end
  end
end
