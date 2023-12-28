class TextFieldComponent < ViewComponent::Base

  erb_template <<-ERB
    <div class="mb-2">
      <%= @form.label @name, @title, class: "block text-neutral-600 dark:text-neutral-300" %>
      <%= @form.text_field @name, class: "p-1" %>
    </div>
  ERB

  def initialize(form:, name:, title:)
    @form = form
    @name = name
    @title = title
  end

end
