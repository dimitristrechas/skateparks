require 'rails_helper'

RSpec.describe LinkButtonComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:title) { 'Explore' }
  let(:url) { '/explore' }
  let(:target) { '_self' }
  let(:current) { false }
  let(:ghost) { false }
  let(:large) { false }
  let(:component) { described_class.new(title:, url:, target:, current:, ghost:, large:) }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    it 'renders anchor with visible title' do
      aggregate_failures do
        expect(rendered).to have_css('a', text: title)
        expect(rendered).to have_link(title, href: url)
      end
    end

    context 'when current true' do
      let(:current) { true }

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
        expect(html).to include('min-h-8')
        expect(html).to include('min-w-8')
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

    context 'when ghost and current both true' do
      it 'raises ArgumentError' do
        expect { described_class.new(title:, url:, ghost: true, current: true) }
          .to raise_error(ArgumentError, 'only one of ghost, contained, current can be true')
      end
    end

    context 'when ghost and contained both true' do
      it 'raises ArgumentError' do
        expect { described_class.new(title:, url:, ghost: true, contained: true) }
          .to raise_error(ArgumentError, 'only one of ghost, contained, current can be true')
      end
    end

    context 'when current and contained both true' do
      it 'raises ArgumentError' do
        expect { described_class.new(title:, url:, current: true, contained: true) }
          .to raise_error(ArgumentError, 'only one of ghost, contained, current can be true')
      end
    end

    context 'when ghost, contained, and current all true' do
      it 'raises ArgumentError' do
        expect { described_class.new(title:, url:, ghost: true, contained: true, current: true) }
          .to raise_error(ArgumentError, 'only one of ghost, contained, current can be true')
      end
    end

    context 'when large true' do
      let(:large) { true }

      it 'includes large size classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('text-xl')
          expect(html).to include('px-6')
          expect(html).to include('py-3')
        end
      end
    end

    context 'with icon_before slot' do
      it 'renders icon before title' do
        html = render_inline(component) do |c|
          c.with_icon_before { '<svg class="test-icon-before"></svg>'.html_safe }
        end

        expect(html.to_html).to include('test-icon-before')
        expect(html.css('.flex.items-center.gap-2')).to be_present
      end
    end

    context 'with icon_after slot' do
      it 'renders icon after title' do
        html = render_inline(component) do |c|
          c.with_icon_after { '<svg class="test-icon-after"></svg>'.html_safe }
        end

        expect(html.to_html).to include('test-icon-after')
      end
    end

    context 'with both icon slots' do
      it 'renders both icons in correct order' do
        html = render_inline(component) do |c|
          c.with_icon_before { '<svg class="icon-before"></svg>'.html_safe }
          c.with_icon_after { '<svg class="icon-after"></svg>'.html_safe }
        end

        content = html.to_html
        expect(content.index('icon-before')).to be < content.index(title)
        expect(content.index(title)).to be < content.index('icon-after')
      end
    end
  end
end
