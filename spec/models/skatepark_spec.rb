require 'rails_helper'

RSpec.describe Skatepark do
  describe 'validations' do
    it 'requires name to be present' do
      skatepark = build(:skatepark)
      skatepark.name = nil
      expect(skatepark.save).to be false
    end

    it 'requires cover_image to be present' do
      skatepark = build(:skatepark)
      skatepark.cover_image = nil
      expect(skatepark.save).to be false
    end

    it 'requires lat to be present' do
      skatepark = build(:skatepark)
      skatepark.lat = nil
      expect(skatepark.save).to be false
    end

    it 'requires lng to be present' do
      skatepark = build(:skatepark)
      skatepark.lng = nil
      expect(skatepark.save).to be false
    end

    it 'requires description to be present' do
      skatepark = build(:skatepark)
      skatepark.description = nil
      expect(skatepark.save).to be false
    end

    it 'requires at least 2 images to be present' do
      skatepark = build(:skatepark, images: [fixture_file_upload('sample_image1.jpg')])
      expect(skatepark.save).to be false
    end

    it 'requires status to be present and valid' do
      skatepark = build(:skatepark, status: nil)
      expect(skatepark.save).to be false

      skatepark.status = :published
      expect(skatepark.save).to be true
    end

    it 'generates a slug based on the name' do
      skatepark = build(:skatepark, name_en: 'Test Skatepark', name_el: 'Test Skatepark')
      skatepark.save
      expect(skatepark.slug).to eq('test-skatepark')
    end

    it 'updates the slug when the name changes' do
      skatepark = create(:skatepark, name_en: 'Test Skatepark', name_el: 'Test Skatepark')
      skatepark.update(name_en: 'Updated Name')
      expect(skatepark.slug).to eq('updated-name')
    end

    it 'returns the correct format in to_param' do
      skatepark = create(:skatepark, :us_location,
                         name_en: 'Chicago Skate Park',
                         name_el: 'Chicago Skate Park',
                         state: 'IL',
                         lat: 41.8819,
                         lng: -87.6231)

      expect(skatepark.to_param).to eq("#{skatepark.id}-chicago-skate-park")
    end
  end
end
