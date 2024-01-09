class TitleComponent < ViewComponent::Base

  erb_template <<-ERB
    <h1 class="text-4xl text-neutral-600 dark:text-neutral-300 font-semibold mb-2 <%= @classnames.to_s.rstrip %>"><%= @title %></h1>
  ERB

  def initialize(title:, classnames: nil)
    @title = title
    @classnames = classnames
  end
end