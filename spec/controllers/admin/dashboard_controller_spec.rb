require 'rails_helper'

RSpec.describe Admin::DashboardController do
  before do
    allow(controller).to receive(:http_basic_authenticate_or_request_with)
                     .with(anything).and_return true
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
