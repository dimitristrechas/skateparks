require 'application_system_test_case'

class AdminAccessTest < ApplicationSystemTestCase
  test 'guest is sent to sign in' do
    visit admin_root_path

    assert_current_path new_session_path
  end

  test 'admin signs in and reaches the admin pages' do
    skatepark = create(:skatepark)
    sign_in_as create(:user, :admin)

    assert_selector 'h1', text: I18n.t('admin.dashboard.title')

    visit admin_skateparks_path

    assert_text skatepark.name_en

    visit admin_users_path

    assert_no_selector '.translation_missing', visible: :all
  end

  test 'regular user is denied admin access' do
    sign_in_as create(:user)
    visit admin_root_path

    assert_current_path root_path
    assert_no_text I18n.t('admin.dashboard.title')
  end
end
