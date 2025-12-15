require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  let!(:published_skatepark) { create(:skatepark) }
  let!(:draft_skatepark) { create(:skatepark, :draft) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns only published skateparks to @skateparks' do
      get :index
      expect(assigns(:skateparks)).to eq([published_skatepark])
    end

    it 'assigns the locale from params to @locale' do
      get :index, params: { locale: 'el' }
      expect(assigns(:locale)).to eq('el')
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
