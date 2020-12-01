FactoryBot.define do
  factory :ticket do
    pending
    lending

    association :reader
    association :copy

    trait :reservation do
      type { "Reservation" }
    end

    trait :lending do
      type { "Lending" }
    end

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
