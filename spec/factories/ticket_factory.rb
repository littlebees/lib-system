FactoryBot.define do
  factory :ticket do
    pending

    association :reader
    association :copy

    trait :Reservation do
      type { "Reservation" }
    end

    trait :Lending do
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
