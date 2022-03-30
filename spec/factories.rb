FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    provider { "sso" }
    sequence(:uid) { |n| "1234#{n}" }
    roles { [] }
    trait :admin do
      roles { ["admin"] }
    end
    trait :cms do
      roles { ["cms"] }
    end
    trait :events do
      roles { ["events"] }
    end
  end
end
