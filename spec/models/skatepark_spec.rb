require 'rails_helper'

RSpec.describe Skatepark, type: :model do

  describe "validations" do
    it "requires name to be present" do
      skatepark = Skatepark.new(cover_image: fixture_file_upload('sample_image2.jpg'),
                                lat: 12.345,
                                lng: 67.890,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: :published)

      skatepark.name = nil
      expect(skatepark.save).to be false
    end

    it "requires cover_image to be present" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                lat: 12.345,
                                lng: 67.890,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: :published)

      skatepark.cover_image = nil
      expect(skatepark.save).to be false
    end

    it "requires lat to be present" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                cover_image: fixture_file_upload('sample_image2.jpg'),
                                lng: 67.890,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: :published)

      skatepark.lat = nil
      expect(skatepark.save).to be false
    end

    it "requires lng to be present" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                cover_image: fixture_file_upload('sample_image2.jpg'),
                                lat: 12.345,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: :published)

      skatepark.lng = nil
      expect(skatepark.save).to be false
    end

    it "requires description to be present" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                cover_image: fixture_file_upload('sample_image2.jpg'),
                                lat: 12.345,
                                lng: 67.890,
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: :published)

      skatepark.description = nil
      expect(skatepark.save).to be false
    end

    it "requires at least 2 images to be present" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                cover_image: fixture_file_upload('sample_image2.jpg'),
                                lat: 12.345,
                                lng: 67.890,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg')],
                                status: :published)

      expect(skatepark.save).to be false
    end

    it "requires status to be present and valid" do
      skatepark = Skatepark.new(name: "Test Skatepark",
                                cover_image: fixture_file_upload('sample_image2.jpg'),
                                lat: 12.345,
                                lng: 67.890,
                                description: "Skatepark description",
                                images: [fixture_file_upload('sample_image1.jpg'), fixture_file_upload('sample_image3.jpg')],
                                status: nil)

      expect(skatepark.save).to be false

      skatepark.status = :published
      expect(skatepark.save).to be true
    end
  end
end
