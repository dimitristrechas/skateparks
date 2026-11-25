require 'application_system_test_case'

class PublicPagesTest < ApplicationSystemTestCase
  STATIC_PATHS = %w[/ /about /contact /privacy /skateparks /session/new].freeze

  test 'public pages render in every locale without missing translations' do
    I18n.available_locales.each do |locale|
      STATIC_PATHS.each do |path|
        visit localized_path(path, locale)

        assert_selector "html[lang='#{locale}']", visible: :all
        assert_no_selector '.translation_missing', visible: :all
      end
    end
  end

  test 'skatepark page renders the translated name' do
    skatepark = create(:skatepark)

    I18n.available_locales.each do |locale|
      visit localized_path(skatepark_path(skatepark), locale)

      assert_selector 'h1', text: skatepark.public_send("name_#{locale}")
    end
  end
end
