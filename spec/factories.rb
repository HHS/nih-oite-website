FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    provider { "sso" }
    sequence(:uid) { |n| "1234#{n}" }
    role { "" }
    trait :admin do
      role { "admin" }
    end
    trait :cms do
      role { "cms" }
    end
  end
end
