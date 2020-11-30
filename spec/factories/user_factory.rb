FactoryBot.define do
  sequence(:reader_email) { |n| "read#{n}@example.com" }

  sequence(:librarian_email) { |n| "lib#{n}@example.com" }

  factory :reader
  factory :librarian

  factory :user do
    as_reader # default
    password { "12345678" }

    trait :as_reader do
      email { generate :reader_email }
      association :role, factory: :reader
    end

    trait :as_librarian do
      email { generate :librarian_email }
      association :role, factory: :librarian
    end
  end
end