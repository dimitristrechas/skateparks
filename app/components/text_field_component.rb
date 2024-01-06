class TextFieldComponent < ViewComponent::Base

  erb_template <<-ERB
    <div class="<%= @classnames.to_s.rstrip %>">
      <%= @form.label @name, @title, class: "block text-neutral-600 dark:text-neutral-300 mb-1" %>
      <%= @form.text_field @name, class: "text-neutral-600 w-1/2 p-1 rounded" %>
    </div>
  ERB

  def initialize(form:, name:, title:, classnames: nil)
    @form = form
    @name = name
    @title = title
    @classnames = classnames
  end

end
