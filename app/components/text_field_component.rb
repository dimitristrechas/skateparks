class TextFieldComponent < ViewComponent::Base
  def initialize(form:, name:, title:, classnames: nil)
    super
    @form = form
    @name = name
    @title = title
    @classnames = classnames
  end

end
