require 'rails_helper'

RSpec.describe ButtonComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:title) { 'Submit' }
  let(:type) { :submit }
  let(:form) { nil }
  let(:ghost) { false }
  let(:component) { described_class.new(title:, type:, form:, ghost:) }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    context 'without form' do
      it 'renders button_tag with title' do
        expect(rendered).to have_button(title, type: 'submit')
      end
    end

    context 'with form' do
      let(:form) { instance_double(ActionView::Helpers::FormBuilder) }

      before do
        allow(form).to receive(:button).and_return('<button type="submit">Submit</button>'.html_safe)
      end

      it 'uses form.button' do
        render_inline(component)
        expect(form).to have_received(:button)
      end
    end

    it 'includes base hover outline classes' do
      html = rendered.to_html
      expect(html).to include('hover:outline')
    end

    it 'includes min touch target size classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('min-h-8')
        expect(html).to include('min-w-8')
      end
    end

    context 'with default styling' do
      it 'includes pink background classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('bg-pink-600/85')
          expect(html).to include('text-white')
          expect(html).to include('dark:bg-pink-600/65')
        end
      end

      it 'does not include ghost outline classes' do
        html = rendered.to_html
        expect(html).not_to include('outline-gray-400')
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

      it 'does not include pink background classes' do
        html = rendered.to_html
        expect(html).not_to include('bg-pink-600/85')
      end
    end

    context 'when large true' do
      let(:component) { described_class.new(title:, type:, large: true) }

      it 'includes large size classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('text-xl')
          expect(html).to include('px-6')
          expect(html).to include('py-3')
        end
      end
    end
  end
end
