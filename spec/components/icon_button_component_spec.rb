require 'rails_helper'

RSpec.describe IconButtonComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:aria_label) { 'Toggle theme' }
  let(:html_options) { {} }
  let(:component) { described_class.new(aria_label:, **html_options) }

  describe '#render' do
    subject(:rendered) { render_inline(component) { |c| c.with_icon { icon_svg } } }

    let(:icon_svg) { '<svg class="test-icon" aria-hidden="true"></svg>'.html_safe }

    it 'renders button with aria-label' do
      expect(rendered).to have_css("button[aria-label='#{aria_label}']")
    end

    it 'renders button with type=button by default' do
      expect(rendered).to have_button(type: 'button')
    end

    it 'renders icon slot content' do
      expect(rendered).to have_css('svg.test-icon')
    end

    it 'includes base styling classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('rounded-lg')
        expect(html).to include('p-1.5')
        expect(html).to include('cursor-pointer')
      end
    end

    it 'includes min touch target size classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('min-h-8')
        expect(html).to include('min-w-8')
      end
    end

    it 'includes hover outline classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('hover:outline')
        expect(html).to include('hover:outline-offset-1')
        expect(html).to include('hover:outline-neutral-700')
        expect(html).to include('dark:hover:outline-neutral-200')
      end
    end

    it 'includes focus-visible outline classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('focus-visible:outline')
        expect(html).to include('focus-visible:outline-offset-1')
        expect(html).to include('focus-visible:outline-neutral-700')
        expect(html).to include('dark:focus-visible:outline-neutral-200')
      end
    end

    context 'with custom id' do
      let(:html_options) { { id: 'theme-toggle' } }

      it 'passes through id attribute' do
        expect(rendered).to have_button(id: 'theme-toggle')
      end
    end

    context 'with data attributes' do
      let(:html_options) { { data: { action: 'click->header#toggleThemeMode' } } }

      it 'passes through data-action attribute' do
        expect(rendered).to have_css("button[data-action='click->header#toggleThemeMode']")
      end
    end

    context 'with custom type' do
      let(:html_options) { { type: 'submit' } }

      it 'allows overriding type' do
        expect(rendered).to have_button(type: 'submit')
      end
    end

    context 'with additional classes' do
      let(:html_options) { { class: 'custom-class' } }

      it 'merges custom classes with base classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('rounded-lg')
          expect(html).to include('custom-class')
        end
      end
    end
  end

  describe 'initialization' do
    it 'requires aria_label' do
      expect { described_class.new }.to raise_error(ArgumentError, /aria_label/)
    end

    it 'requires icon slot' do
      expect { render_inline(component) }.to raise_error(ArgumentError, /icon slot is required/)
    end
  end
end
