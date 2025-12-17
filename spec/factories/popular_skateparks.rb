FactoryBot.define do
  factory :popular_skatepark do
    skatepark
    sequence(:position) { |n| n }
  end
end
