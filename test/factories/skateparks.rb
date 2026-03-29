FactoryBot.define do
  factory :skatepark do
    transient do
      skatepark_images_count { 2 }
    end

    sequence(:name_en) { |n| "#{Faker::Address.community} Skatepark #{n}" }
    sequence(:name_el) { |n| "#{Faker::Address.community} Σκέιτπαρκ #{n}" }

    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    country_code { 'GR' }
    state { 'I' }

    description_en { Faker::Lorem.paragraph(sentence_count: 3) }
    description_el { Faker::Lorem.paragraph(sentence_count: 3) }

    status { :published }

    trait :draft do
      status { :draft }
    end

    trait :archived do
      status { :archived }
    end

    trait :us_location do
      country_code { 'US' }
      state { 'CA' }
    end

    after(:build) do |skatepark, evaluator|
      unless skatepark.cover_image.attached?
        skatepark.cover_image.attach(
          Rack::Test::UploadedFile.new(
            Rails.root.join('test/fixtures/files/sample_image2.jpg'),
            'image/jpeg'
          )
        )
      end

      next unless skatepark.skatepark_images.empty?

      evaluator.skatepark_images_count.times do |index|
        image_path = index.even? ? 'sample_image1.jpg' : 'sample_image3.jpg'
        skatepark_image = skatepark.skatepark_images.build(position: index + 1)
        skatepark_image.image.attach(
          Rack::Test::UploadedFile.new(
            Rails.root.join("test/fixtures/files/#{image_path}"),
            'image/jpeg'
          )
        )
      end
    end
  end
end
