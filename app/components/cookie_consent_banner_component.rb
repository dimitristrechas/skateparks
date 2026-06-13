class CookieConsentBannerComponent < ViewComponent::Base
  private

  def base_button_classes
    'inline-flex items-center rounded-lg px-3 min-h-8 min-w-8 ' \
      'hover:outline hover:outline-offset-1 hover:outline-neutral-700 hover:dark:outline-neutral-200 ' \
      'focus-visible:outline focus-visible:outline-offset-1 focus-visible:outline-neutral-700 ' \
      'focus-visible:dark:outline-neutral-200 cursor-pointer'
  end

  def action_button_classes
    class_names(
      base_button_classes,
      'outline outline-gray-400 bg-neutral-100 dark:outline-gray-500 dark:bg-neutral-800'
    )
  end
end
