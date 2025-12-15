FactoryBot.define do
  factory :popular_skatepark do
    association :skatepark
    sequence(:position) { |n| n }
  end
end
