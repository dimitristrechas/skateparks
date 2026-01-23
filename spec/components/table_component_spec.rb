# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TableComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers

  let(:component) { described_class.new }

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    context 'with header and rows' do
      subject(:rendered) do
        render_inline(component) do |table|
          table.with_header do
            '<th>Name</th><th>Status</th>'.html_safe
          end
          table.with_row { '<td>Park 1</td><td>Active</td>'.html_safe }
          table.with_row { '<td>Park 2</td><td>Draft</td>'.html_safe }
        end
      end

      it 'renders outer wrapper with shadow and rounded classes' do
        expect(rendered.to_html).to include('shadow-md')
        expect(rendered.to_html).to include('sm:rounded-lg')
      end

      it 'renders table element' do
        expect(rendered).to have_table
      end

      it 'renders header inside thead' do
        expect(rendered).to have_css('thead th', text: 'Name')
        expect(rendered).to have_css('thead th', text: 'Status')
      end

      it 'renders rows inside tbody' do
        expect(rendered).to have_css('tbody tr', count: 2)
        expect(rendered).to have_css('tbody td', text: 'Park 1')
        expect(rendered).to have_css('tbody td', text: 'Park 2')
      end

      it 'applies alternating row styles' do
        expect(rendered.to_html).to include('odd:bg-white')
        expect(rendered.to_html).to include('even:bg-gray-50')
      end
    end

    context 'with header only (no rows)' do
      subject(:rendered) do
        render_inline(component) do |table|
          table.with_header do
            '<th>Name</th>'.html_safe
          end
        end
      end

      it 'renders table with empty tbody' do
        expect(rendered).to have_table
        expect(rendered).to have_css('thead th', text: 'Name')
        expect(rendered).to have_css('tbody')
        expect(rendered).to have_no_css('tbody tr')
      end
    end
  end
end
