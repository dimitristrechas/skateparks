class LinkComponent < ViewComponent::Base

  erb_template <<-ERB
    <%= link_to @title,
                @url,
                class: ("text-blue-700 dark:text-blue-400 hover:underline " + @classnames.to_s).rstrip %>
  ERB

  def initialize(title:, url:, classnames: nil)
    @title = title
    @url = url
    @classnames = classnames
  end

end
