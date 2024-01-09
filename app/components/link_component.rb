class LinkComponent < ViewComponent::Base

  erb_template <<-ERB
    <%= link_to @title,
                @url,
                target: @target,
                class: ("text-blue-700 dark:text-blue-400 hover:underline " + @classnames.to_s).rstrip %>
  ERB

  def initialize(title:, url:, classnames: nil, target: "_self")
    @title = title
    @url = url
    @classnames = classnames
    @target = target
  end

end
