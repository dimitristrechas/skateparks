# frozen_string_literal: true

require 'test_helper'

class FormErrorsComponentTest < ViewComponent::TestCase
  def test_renders_nothing_when_the_model_has_no_errors
    render_inline(FormErrorsComponent.new(model: User.new))

    assert_predicate rendered_content.strip, :blank?
  end

  def test_renders_custom_heading_and_full_messages
    user = User.new
    user.errors.add(:base, 'Name is required')
    user.errors.add(:email_address, 'is invalid')

    render_inline(FormErrorsComponent.new(model: user, heading: 'Profile could not be saved'))

    assert_selector '#error_explanation[role="alert"]'
    assert_selector 'h2', text: 'Profile could not be saved'
    assert_selector 'li', text: 'Name is required'
    assert_selector 'li', text: 'Email address is invalid'
    assert_includes rendered_content, 'mt-3 rounded-lg bg-red-50 px-3 py-2 font-medium text-red-500'
  end

  def test_renders_generic_heading_for_one_error
    user = User.new
    user.errors.add(:base, 'Name is required')

    render_inline(FormErrorsComponent.new(model: user))

    assert_selector 'h2', text: I18n.t('form_errors.heading', count: 1)
    assert_selector 'li', count: 1
  end

  def test_renders_generic_heading_in_greek
    user = User.new
    user.errors.add(:base, 'Name is required')
    user.errors.add(:base, 'City is required')

    I18n.with_locale(:el) do
      render_inline(FormErrorsComponent.new(model: user))
    end

    assert_selector 'h2', text: I18n.t('form_errors.heading', count: 2, locale: :el)
  end

  def test_escapes_message_text
    user = User.new
    user.errors.add(:base, '<script>alert(1)</script>')

    render_inline(FormErrorsComponent.new(model: user, heading: 'Could not save'))

    assert_includes rendered_content, '&lt;script&gt;alert(1)&lt;/script&gt;'
    assert_not_includes rendered_content, '<script>'
  end
end
