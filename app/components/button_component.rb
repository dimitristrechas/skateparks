class ButtonComponent < ViewComponent::Base
  def initialize(title:, form:, type:)
    super
    @title = title
    @form = form
    @type = type
  end
end
