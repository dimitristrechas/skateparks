require 'rails_helper'

RSpec.describe HomepageSkateparkCardComponent, type: :component do
  include ViewComponent::TestHelpers
  include Capybara::RSpecMatchers
  include Rails.application.routes.url_helpers

  let(:skatepark) { create(:skatepark) }
  let(:badge_type) { :new }
  let(:component) { described_class.new(skatepark:, badge_type:) }

  before do
    allow_any_instance_of(CloudinaryHelper).to receive(:cl_image_tag) do |_helper, _key, options|
      ActionController::Base.helpers.tag.img(src: 'https://res.cloudinary.com/test/image.jpg', alt: options[:alt])
    end
  end

  describe '#render' do
    subject(:rendered) { render_inline(component) }

    it 'renders link to skatepark' do
      expect(rendered.to_html).to include(skatepark_path(skatepark))
    end

    it 'renders skatepark name' do
      expect(rendered).to have_text(skatepark.name)
    end

    it 'renders photo count' do
      expect(rendered).to have_text("#{skatepark.images.size} #{I18n.t('photos')}")
    end

    it 'renders cover image with alt text' do
      expect(rendered).to have_css("img[alt='#{skatepark.name} cover image']")
    end

    context 'with new badge_type' do
      let(:badge_type) { :new }

      it 'renders new badge' do
        expect(rendered).to have_text(I18n.t(:new))
      end
    end

    context 'with popular badge_type' do
      let(:badge_type) { :popular }

      it 'renders popular badge' do
        expect(rendered).to have_text(I18n.t(:popular))
      end
    end
  end
end
