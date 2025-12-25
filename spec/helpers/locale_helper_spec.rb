require 'rails_helper'

RSpec.describe LocaleHelper do
  describe '#locale_selector' do
    let(:params) { { country_code: 'GR', state: 'I', page: '2' } }

    before do
      allow(helper).to receive(:params).and_return(params)
      allow(helper).to receive(:link_to) do |text, options|
        query = options.map { |k, v| "#{k}=#{v}" }.join('&')
        "<a href=\"?#{query}\">#{text}</a>"
      end
    end

    it 'renders the active locale' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('Ελληνικά')
      end
    end

    it 'generates links for all available locales' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('Ελληνικά')
        expect(result).to include('English')
      end
    end

    it 'preserves country_code param in links' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('country_code=GR')
      end
    end

    it 'preserves state param in links' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('state=I')
      end
    end

    it 'preserves page param in links' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('page=2')
      end
    end

    context 'when params are nil' do
      let(:params) { {} }

      it 'generates links without nil params' do
        I18n.with_locale(:el) do
          result = helper.locale_selector
          expect(result).not_to include('country_code')
          expect(result).not_to include('state')
          expect(result).not_to include('page')
        end
      end
    end

    context 'when locale is English' do
      it 'displays English as active locale' do
        I18n.with_locale(:en) do
          result = helper.locale_selector
          expect(result).to include('English')
        end
      end
    end

    it 'includes correct CSS classes' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result).to include('class="relative"')
        expect(result).to include('class="cursor-pointer"')
        expect(result).to include('class="absolute inset-x-0 bottom-0 bg-white"')
      end
    end

    it 'generates list items for each locale' do
      I18n.with_locale(:el) do
        result = helper.locale_selector
        expect(result.scan('<li>').count).to eq(I18n.available_locales.count)
      end
    end
  end

  describe 'LOCALES constant' do
    it 'defines Greek locale' do
      expect(LocaleHelper::LOCALES[:el]).to eq('Ελληνικά')
    end

    it 'defines English locale' do
      expect(LocaleHelper::LOCALES[:en]).to eq('English')
    end

    it 'is frozen' do
      expect(LocaleHelper::LOCALES).to be_frozen
    end
  end
end
