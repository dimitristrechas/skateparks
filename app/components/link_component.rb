class LinkComponent < ViewComponent::Base

  erb_template <<-ERB
    <%= link_to @title,
                @url,
                class: "text-blue-700 dark:text-blue-400 hover:underline #{@classNames}".rstrip %>
  ERB

  def initialize(title:, url:, classNames: nil)
    @title = title
    @url = url
    @classNames = classNames
  end

end
