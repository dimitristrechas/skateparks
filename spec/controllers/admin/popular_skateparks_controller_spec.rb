require 'rails_helper'

RSpec.describe Admin::PopularSkateparksController do
  let!(:first_published_skatepark) { create(:skatepark) }
  let!(:second_published_skatepark) { create(:skatepark) }
  let!(:draft_skatepark) { create(:skatepark, :draft) }
  let!(:first_popular_skatepark) { create(:popular_skatepark, skatepark: first_published_skatepark, position: 1) }
  let!(:second_popular_skatepark) { create(:popular_skatepark, skatepark: second_published_skatepark, position: 2) }

  before do
    allow(controller).to receive(:http_basic_authenticate_or_request_with)
                     .with(anything).and_return true
  end

  describe 'GET #index' do
    it 'returns success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all popular skateparks with skateparks included' do
      get :index
      expect(assigns(:popular_skateparks)).to contain_exactly(first_popular_skatepark, second_popular_skatepark)
    end

    it 'assigns available published skateparks not in popular list' do
      unpopular_skatepark = create(:skatepark)
      get :index
      available = assigns(:available_skateparks)

      expect(available).to include(unpopular_skatepark)
      expect(available).not_to include(first_published_skatepark)
      expect(available).not_to include(second_published_skatepark)
      expect(available).not_to include(draft_skatepark)
    end
  end

  describe 'POST #create' do
    let(:unpopular_skatepark) { create(:skatepark) }
    let(:valid_params) do
      {
        popular_skatepark: {
          skatepark_id: unpopular_skatepark.id,
          position: 3,
        },
      }
    end

    context 'with valid parameters' do
      it 'creates new popular skatepark' do
        expect do
          post :create, params: valid_params
        end.to change(PopularSkatepark, :count).by(1)
      end

      it 'assigns correct attributes' do
        post :create, params: valid_params
        popular = PopularSkatepark.last

        expect(popular.skatepark_id).to eq(unpopular_skatepark.id)
        expect(popular.position).to eq(3)
      end

      it 'redirects to index' do
        post :create, params: valid_params
        expect(response).to redirect_to(admin_popular_skateparks_url)
      end

      it 'sets flash notice' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq(I18n.t('admin.popular_skateparks.added_notice'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create popular skatepark with duplicate skatepark_id' do
        invalid_params = {
          popular_skatepark: {
            skatepark_id: first_published_skatepark.id,
            position: 4,
          },
        }
        expect do
          post :create, params: invalid_params
        end.not_to change(PopularSkatepark, :count)
      end

      it 'renders index template' do
        invalid_params = {
          popular_skatepark: {
            skatepark_id: first_published_skatepark.id,
            position: 4,
          },
        }
        post :create, params: invalid_params
        expect(response).to render_template(:index)
      end

      it 'returns unprocessable content status' do
        invalid_params = {
          popular_skatepark: {
            skatepark_id: first_published_skatepark.id,
            position: 4,
          },
        }
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'assigns popular skateparks for re-rendering' do
        invalid_params = {
          popular_skatepark: {
            skatepark_id: first_published_skatepark.id,
            position: 4,
          },
        }
        post :create, params: invalid_params
        expect(assigns(:popular_skateparks)).to contain_exactly(first_popular_skatepark, second_popular_skatepark)
      end

      it 'assigns available skateparks for re-rendering' do
        invalid_params = {
          popular_skatepark: {
            skatepark_id: first_published_skatepark.id,
            position: 4,
          },
        }
        post :create, params: invalid_params
        expect(assigns(:available_skateparks)).not_to be_nil
      end

      it 'does not create popular skatepark without position' do
        expect do
          post :create, params: { popular_skatepark: { skatepark_id: unpopular_skatepark.id, position: nil } }
        end.not_to change(PopularSkatepark, :count)
      end
    end
  end

  describe 'PATCH/PUT #update' do
    context 'with valid parameters' do
      let(:update_params) do
        {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: 10 },
        }
      end

      it 'updates popular skatepark position' do
        patch :update, params: update_params
        first_popular_skatepark.reload

        expect(first_popular_skatepark.position).to eq(10)
      end

      it 'redirects to index' do
        patch :update, params: update_params
        expect(response).to redirect_to(admin_popular_skateparks_url)
      end

      it 'sets flash notice' do
        patch :update, params: update_params
        expect(flash[:notice]).to eq(I18n.t('admin.popular_skateparks.updated_notice'))
      end

      it 'clears cache after update' do
        allow(Rails.cache).to receive(:delete).with('skateparks_popular')
        patch :update, params: update_params
        expect(Rails.cache).to have_received(:delete).with('skateparks_popular')
      end
    end

    context 'with invalid parameters' do
      it 'does not update popular skatepark' do
        original_position = first_popular_skatepark.position
        invalid_update_params = {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: nil },
        }
        patch :update, params: invalid_update_params
        first_popular_skatepark.reload

        expect(first_popular_skatepark.position).to eq(original_position)
      end

      it 'renders index template' do
        invalid_update_params = {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: nil },
        }
        patch :update, params: invalid_update_params
        expect(response).to render_template(:index)
      end

      it 'returns unprocessable content status' do
        invalid_update_params = {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: nil },
        }
        patch :update, params: invalid_update_params
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'assigns popular skateparks for re-rendering' do
        invalid_update_params = {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: nil },
        }
        patch :update, params: invalid_update_params
        expect(assigns(:popular_skateparks)).to contain_exactly(first_popular_skatepark, second_popular_skatepark)
      end

      it 'assigns available skateparks for re-rendering' do
        invalid_update_params = {
          id: first_popular_skatepark.id,
          popular_skatepark: { position: nil },
        }
        patch :update, params: invalid_update_params
        expect(assigns(:available_skateparks)).not_to be_nil
      end
    end

    context 'when popular skatepark not found' do
      it 'raises RecordNotFound error' do
        expect do
          patch :update, params: { id: 99_999, popular_skatepark: { position: 5 } }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys popular skatepark' do
      expect do
        delete :destroy, params: { id: first_popular_skatepark.id }
      end.to change(PopularSkatepark, :count).by(-1)
    end

    it 'redirects to index' do
      delete :destroy, params: { id: first_popular_skatepark.id }
      expect(response).to redirect_to(admin_popular_skateparks_url)
    end

    it 'sets flash notice' do
      delete :destroy, params: { id: first_popular_skatepark.id }
      expect(flash[:notice]).to eq(I18n.t('admin.popular_skateparks.removed_notice'))
    end

    it 'clears cache after destroy' do
      allow(Rails.cache).to receive(:delete).with('skateparks_popular')
      delete :destroy, params: { id: first_popular_skatepark.id }
      expect(Rails.cache).to have_received(:delete).with('skateparks_popular')
    end

    it 'does not destroy associated skatepark' do
      skatepark = first_popular_skatepark.skatepark

      expect do
        delete :destroy, params: { id: first_popular_skatepark.id }
      end.not_to change(Skatepark, :count)

      expect(Skatepark.exists?(skatepark.id)).to be true
    end

    context 'when popular skatepark not found' do
      it 'raises RecordNotFound error' do
        expect do
          delete :destroy, params: { id: 999_999 }
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'authentication' do
    before do
      allow(controller).to receive(:http_basic_authenticate_or_request_with)
                       .and_call_original
    end

    context 'in production environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        Rails.application.credentials.config[:admin] = { username: 'nice', password: 'try' }
      end

      it 'requires HTTP basic authentication' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'in development environment' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
      end

      it 'does not require HTTP basic authentication' do
        get :index
        expect(response).to be_successful
      end
    end
  end
end
