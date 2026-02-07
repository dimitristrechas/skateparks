FactoryBot.define do
  factory :skatepark do
    sequence(:name_en) { |n| "#{Faker::Address.community} Skatepark #{n}" }
    sequence(:name_el) { |n| "#{Faker::Address.community} Σκέιτπαρκ #{n}" }

    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    country_code { 'GR' }
    state { 'I' }

    description_en { Faker::Lorem.paragraph(sentence_count: 3) }
    description_el { Faker::Lorem.paragraph(sentence_count: 3) }

    cover_image do
      Rack::Test::UploadedFile.new(
        Rails.root.join('test/fixtures/files/sample_image2.jpg'),
        'image/jpeg'
      )
    end

    images do
      [
        Rack::Test::UploadedFile.new(
          Rails.root.join('test/fixtures/files/sample_image1.jpg'),
          'image/jpeg'
        ),
        Rack::Test::UploadedFile.new(
          Rails.root.join('test/fixtures/files/sample_image3.jpg'),
          'image/jpeg'
        ),
      ]
    end

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
  end
end
