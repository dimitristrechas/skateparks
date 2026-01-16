require 'rails_helper'

RSpec.describe LinkComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:title) { 'About' }
  let(:url) { '/about' }
  let(:target) { '_self' }
  let(:current) { false }
  let(:classnames) { nil }
  let(:component) { described_class.new(title:, url:, target:, current:, classnames:) }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    it 'renders anchor with visible title' do
      aggregate_failures do
        expect(rendered).to have_css('a', text: title)
        expect(rendered).to have_link(title, href: url)
      end
    end

    it 'includes correct base classes' do
      expect(rendered.to_html).to include('hover:underline py-1 px-2')
    end

    context 'when current true' do
      let(:current) { true }

      it 'adds aria-current=page' do
        expect(rendered).to have_css("a[aria-current='page']")
      end

      it 'includes underline classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('underline')
          expect(html).to include('underline-offset-2')
        end
      end
    end

    context 'when current false' do
      let(:current) { false }

      it 'does not add aria-current' do
        expect(rendered).to have_no_css('a[aria-current]')
      end
    end

    context 'when target _self (default)' do
      let(:target) { '_self' }

      it 'does not add rel attribute' do
        expect(rendered).to have_no_css('a[rel]')
      end

      it 'does not include sr-only text' do
        expect(rendered).to have_no_css('span.sr-only')
      end
    end

    context 'when target _blank' do
      let(:target) { '_blank' }

      it 'adds rel noopener noreferrer' do
        expect(rendered).to have_css("a[target='_blank'][rel~='noopener'][rel~='noreferrer']")
      end

      it 'includes sr-only text for screen readers' do
        expect(rendered).to have_css('span.sr-only', text: I18n.t('opens_in_new_tab'))
      end
    end

    context 'with custom classnames' do
      let(:classnames) { 'text-lg font-bold' }

      it 'applies custom classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('text-lg')
          expect(html).to include('font-bold')
        end
      end
    end
  end
end
