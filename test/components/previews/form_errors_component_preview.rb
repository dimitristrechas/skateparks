# frozen_string_literal: true

class FormErrorsComponentPreview < ViewComponent::Preview
  def default_heading
    render(FormErrorsComponent.new(model: user_with_errors))
  end

  def custom_heading
    render(FormErrorsComponent.new(model: user_with_errors, heading: 'Profile could not be saved'))
  end

  private

  def user_with_errors
    User.new.tap do |user|
      user.errors.add(:email_address, :blank)
      user.errors.add(:base, 'Name is required')
    end
  end
end
