class TitleComponent < ViewComponent::Base

  erb_template <<-ERB
    <h1 class="text-3xl text-neutral-600 dark:text-neutral-300 font-semibold mb-2"><%= @title %></h1>
  ERB

  def initialize(title:)
    @title = title
  end
end