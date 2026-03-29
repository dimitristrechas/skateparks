FactoryBot.define do
  factory :skatepark_image do
    transient do
      image_fixture { 'sample_image2.jpg' }
    end

    skatepark
    sequence(:position) { |n| n }

    after(:build) do |skatepark_image, evaluator|
      next if skatepark_image.image.attached?

      skatepark_image.image.attach(
        Rack::Test::UploadedFile.new(
          Rails.root.join("test/fixtures/files/#{evaluator.image_fixture}"),
          'image/jpeg'
        )
      )
    end
  end
end
