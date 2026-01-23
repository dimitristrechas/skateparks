# frozen_string_literal: true

class TableComponentPreview < ViewComponent::Preview
  # @label Default
  def default
    render(TableComponent.new) do |table|
      table.with_header do
        header_cells
      end
      table.with_row { row_cells('Central Park', '12', 'Published') }
      table.with_row { row_cells('Riverside Skatepark', '8', 'Draft') }
      table.with_row { row_cells('Downtown Plaza', '5', 'Published') }
    end
  end

  # @label Empty
  def empty
    render(TableComponent.new) do |table|
      table.with_header do
        header_cells
      end
    end
  end

  private

  # rubocop:disable Rails/OutputSafety
  def header_cells
    <<~HTML.html_safe
      <th scope="col" class="px-6 py-3">Name</th>
      <th scope="col" class="px-6 py-3">Images</th>
      <th scope="col" class="px-6 py-3">Status</th>
    HTML
  end

  def row_cells(name, images, status)
    <<~HTML.html_safe
      <th scope="row" class="px-6 py-4 font-medium whitespace-nowrap text-gray-900 dark:text-white">#{name}</th>
      <td class="px-6 py-4">#{images}</td>
      <td class="px-6 py-4">#{status}</td>
    HTML
  end
  # rubocop:enable Rails/OutputSafety
end
