# frozen_string_literal: true

class TableComponentPreview < ViewComponent::Preview
  def default
    render(TableComponent.new) do |table|
      table.with_header do
        '<th class="px-6 py-3">Name</th><th class="px-6 py-3">Status</th>'.html_safe
      end
      table.with_row do
        '<td class="px-6 py-4">Athens Skatepark</td><td class="px-6 py-4">Published</td>'.html_safe
      end
      table.with_row do
        '<td class="px-6 py-4">Thessaloniki Bowl</td><td class="px-6 py-4">Draft</td>'.html_safe
      end
    end
  end
end
