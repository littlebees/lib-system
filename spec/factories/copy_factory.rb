FactoryBot.define do
  factory :book do
    factory :many_book do
      transient do
        copy_amount { 5 }
        which_book { 1 }
      end
      copies { Array.new(copy_amount) { association(:copy, :book_id => which_book) }}
      #copies { FactoryBot.create_list(:copy, copy_amount) }
    end
  end

  factory :copy do
    on_shelf # default
    book

    trait :on_shelf do
      copy_state { "on_shelf" }
    end

    trait :read_by_someone do
      copy_state { "read_by_someone" }
    end

    trait :reserved do
      copy_state { "reserved" }
    end

    trait :waiting_for_approvment do
      copy_state { "waiting_for_approvment" }
    end
    
    trait :lent do
      copy_state { "lent" }
    end

    trait :lost do
      copy_state { "lost" }
    end

    trait :over_due do
      copy_state { "over_due" }
    end

    trait :waiting_to_be_classified do
      copy_state { "waiting_to_be_classified" }
    end
  end
end