require 'rails_helper'

RSpec.describe LinkButtonComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:title) { 'Explore' }
  let(:url) { '/explore' }
  let(:target) { '_self' }
  let(:active) { false }
  let(:ghost) { false }
  let(:component) { described_class.new(title:, url:, target:, active:, ghost:) }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    it 'renders anchor with visible title' do
      aggregate_failures do
        expect(rendered).to have_css('a', text: title)
        expect(rendered).to have_link(title, href: url)
      end
    end

    context 'when active true' do
      let(:active) { true }

      it 'adds aria-current=page' do
        expect(rendered).to have_css("a[aria-current='page']")
      end
    end

    context 'when inactive' do
      it 'includes hover outline classes' do
        html = rendered.to_html
        expect(html).to include('hover:outline')
      end
    end

    it 'includes min touch target size classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('min-h-11')
        expect(html).to include('min-w-11')
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

    context 'when ghost true' do
      let(:ghost) { true }

      it 'includes ghost outline classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('outline-gray-400')
          expect(html).to include('dark:outline-gray-500')
          expect(html).to include('focus-visible:outline-neutral-700')
          expect(html).to include('dark:focus-visible:outline-neutral-200')
        end
      end
    end

    context 'when ghost and active both true' do
      it 'raises ArgumentError' do
        expect { described_class.new(title:, url:, ghost: true, active: true) }
          .to raise_error(ArgumentError, 'ghost and active cannot both be true')
      end
    end
  end
end
