# frozen_string_literal: true

class SelectComponentPreview < ViewComponent::Preview
  def default
    render(SelectComponent.new(
             name: 'country_code',
             options: options_for_select([%w[Greece GR], %w[Germany DE]], 'GR'),
             aria: { label: 'Country' }
           ))
  end

  def large
    render(SelectComponent.new(
             name: 'country_code',
             options: options_for_select([%w[Greece GR], %w[Germany DE]], 'GR'),
             large: true,
             aria: { label: 'Country' }
           ))
  end

  def disabled
    render(SelectComponent.new(
             name: 'country_code',
             options: options_for_select([%w[Greece GR]], 'GR'),
             disabled: true,
             aria: { label: 'Country' }
           ))
  end
end
