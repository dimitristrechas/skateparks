# frozen_string_literal: true

FactoryBot.define do
  factory :site_announcement do
    sequence(:message_en) { |n| "Site news announcement #{n}" }
    sequence(:message_el) { |n| "Ανακοίνωση ιστότοπου #{n}" }
    sequence(:position)
    published { true }

    trait :draft do
      published { false }
    end

    trait :scheduled_future do
      starts_at { 1.day.from_now }
    end

    trait :expired do
      ends_at { 1.day.ago }
    end

    trait :with_link do
      link_url { '/about' }
      link_label_en { 'Learn more' }
      link_label_el { 'Μάθετε περισσότερα' }
    end
  end
end
