require 'test_helper'

class SeoHelperTest < ActionView::TestCase
  tests SeoHelper

  def test_social_title_falls_back_to_application_title
    assert_equal I18n.t('application.title'), social_title
  end

  def test_social_title_uses_assigned_title
    controller.stubs(:view_assigns).returns({ 'title' => 'Bonn | Skateparks.gr' })

    assert_equal 'Bonn | Skateparks.gr', social_title
  end

  def test_social_description_falls_back_to_application_meta_description
    assert_equal I18n.t('application.meta_description'), social_description
  end

  def test_social_image_falls_back_to_logo
    assert_includes social_image, 'logo-og.png'
  end
end
