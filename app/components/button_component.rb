class ButtonComponent < ViewComponent::Base

  erb_template <<-ERB
    <%= @form.button @title,
                     type: @type,
                     class: "py-2 px-3 text-neutral-200 rounded-md bg-cyan-800 hover:bg-cyan-900 transition-colors shadow" %>
  ERB

  def initialize(title:, form:, type:)
    @title = title
    @form = form
    @type = type
  end
end
