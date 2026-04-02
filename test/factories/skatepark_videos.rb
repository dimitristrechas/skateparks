FactoryBot.define do
  factory :skatepark_video do
    skatepark
    sequence(:youtube_url) { |n| "https://youtu.be/#{format('%011d', n)}" }
    sequence(:position) { |n| n }
  end
end
