FactoryBot.define do
  factory :skatepark_video do
    skatepark
    sequence(:youtube_url) { |n| "https://youtu.be/#{format('%011d', n)}" }
    sequence(:position) { |n| n }
    status { :active }

    trait :pending do
      status { :pending }
      position { 0 }
      proposed_skatepark { skatepark }
    end

    trait :rejected do
      status { :rejected }
      position { 0 }
    end
  end
end
