class LinkComponent < ViewComponent::Base

  erb_template <<-ERB
    <%= link_to  @title,  @url, class: @classNames %>
  ERB

  def initialize(title:, url:, classNames:)
    @title = title
    @url = url
    @classNames = classNames
  end

end
