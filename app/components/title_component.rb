class TitleComponent < ViewComponent::Base
  def initialize(title:, classnames: nil)
    super
    @title = title
    @classnames = classnames
  end
end
