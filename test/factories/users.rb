FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { 'password123456' }
    role { :user }

    trait :admin do
      role { :admin }
    end

    trait :banned do
      banned_at { Time.current }
      ban_reason { 'Test ban' }
    end
  end
end
