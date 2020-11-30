FactoryBot.define do
  factory :ticket do
    pending

    association :reader
    association :copy

    trait :pending do
      ticket_state { "pending" }
    end

    trait :approved do
      ticket_state { "approved" }
    end

    trait :recording do
      ticket_state { "recording" }
    end
  end
end