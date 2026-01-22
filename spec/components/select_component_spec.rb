require 'rails_helper'

RSpec.describe SelectComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:name) { :country }
  let(:options) { [['All', ''], ['USA', 'us'], ['Canada', 'ca']] }
  let(:selected) { nil }
  let(:disabled) { false }
  let(:large) { false }
  let(:component) { described_class.new(name:, options:, selected:, disabled:, large:) }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    it 'renders select with correct name' do
      expect(rendered).to have_select('country')
    end

    it 'renders all options' do
      aggregate_failures do
        expect(rendered).to have_css('option', text: 'All')
        expect(rendered).to have_css('option', text: 'USA')
        expect(rendered).to have_css('option', text: 'Canada')
      end
    end

    it 'includes neutral background classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('bg-white')
        expect(html).to include('dark:bg-neutral-700')
      end
    end

    it 'includes neutral border classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('border-neutral-300')
        expect(html).to include('dark:border-neutral-600')
      end
    end

    it 'includes focus-visible outline classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('focus-visible:outline')
        expect(html).to include('focus-visible:outline-offset-1')
        expect(html).to include('focus-visible:outline-neutral-700')
      end
    end

    it 'includes hover outline classes' do
      html = rendered.to_html
      aggregate_failures do
        expect(html).to include('hover:outline')
        expect(html).to include('hover:outline-neutral-700')
        expect(html).to include('dark:hover:outline-neutral-200')
      end
    end

    context 'with selected value' do
      let(:selected) { 'us' }

      it 'marks the correct option as selected' do
        expect(rendered).to have_css('option[selected][value="us"]')
      end
    end

    context 'when disabled' do
      let(:disabled) { true }

      it 'renders disabled select' do
        expect(rendered).to have_css('select[disabled]')
      end

      it 'includes disabled styling classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('disabled:opacity-50')
          expect(html).to include('disabled:cursor-not-allowed')
        end
      end
    end

    context 'when large' do
      let(:large) { true }

      it 'includes large size classes' do
        html = rendered.to_html
        aggregate_failures do
          expect(html).to include('px-6')
          expect(html).to include('py-2.5')
        end
      end
    end

    context 'with custom HTML options' do
      let(:component) do
        described_class.new(
          name:,
          options:,
          data: { 'controller-target': 'select' }
        )
      end

      it 'passes data attributes to select' do
        expect(rendered).to have_css('select[data-controller-target="select"]')
      end
    end

    context 'with custom id' do
      let(:component) { described_class.new(name:, options:, id: 'custom-select') }

      it 'renders select with custom id' do
        expect(rendered).to have_select('custom-select')
      end
    end

    context 'when required' do
      let(:component) { described_class.new(name:, options:, required: true) }

      it 'renders required attribute' do
        expect(rendered).to have_css('select[required]')
      end

      it 'auto-sets aria-required' do
        expect(rendered).to have_css('select[aria-required="true"]')
      end
    end

    context 'with aria-label' do
      let(:component) { described_class.new(name:, options:, aria_label: 'Select your country') }

      it 'renders aria-label attribute' do
        expect(rendered).to have_css('select[aria-label="Select your country"]')
      end
    end

    context 'with aria-describedby' do
      let(:component) { described_class.new(name:, options:, aria_describedby: 'country-help') }

      it 'renders aria-describedby attribute' do
        expect(rendered).to have_css('select[aria-describedby="country-help"]')
      end
    end

    context 'with explicit aria-required' do
      let(:component) { described_class.new(name:, options:, aria_required: true) }

      it 'renders aria-required attribute' do
        expect(rendered).to have_css('select[aria-required="true"]')
      end
    end

    context 'with aria-invalid' do
      let(:component) { described_class.new(name:, options:, aria_invalid: true) }

      it 'renders aria-invalid attribute' do
        expect(rendered).to have_css('select[aria-invalid="true"]')
      end
    end
  end
end
