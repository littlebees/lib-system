class Copy < ApplicationRecord
  include AASM
  belongs_to :book
  has_many :readers

  aasm column: 'copy_state' do
    state :on_shelf, inital: true
    state :read_by_someone, :reserved
    state :waiting_for_approvment
    state :lent, :lost, :over_due
    state :waiting_to_be_classified

    event :take_this_book do
      transitions from: :on_shelf, to: :read_by_someone
    end

    event :put_it_back_to_shelf do
      transitions from: :read_by_someone, to: :on_shelf
    end

    event :borrow_this_book do
      before do
        # generate a ticket
        # generate take lent
      end
      transitions from: [:on_shelf, :read_by_someone], to: :waiting_for_approvment
    end

    event :take_reserved_book do
      before do
        # generate a ticket
        # generate take resv
      end
      transitions from: :reserved, to: :waiting_for_approvment
    end

    event :lend_this_book do
      before do
        # change ticket status
      end
      transitions from: :waiting_for_approvment, to: :lent
    end

    event :mark_over_due do
      before do
        # change ticket status
      end
      transitions from: :lent, to: :over_due
    end

    event :mark_lost do
      before do
        # change ticket status
      end
      transitions from: [:on_shelf, :lent, :over_due], to: :lost
    end

    event :get_lent_book do
      before do
        # change ticket status
      end
      transitions from: [:lent, :over_due], to: :waiting_to_be_classified
    end

    event :put_this_book_onto_shelf do
      transitions from: :waiting_to_be_classified, to: :on_shelf
    end

    event :keep_for_reservation do
      transitions from: :waiting_to_be_classified, to: :reserved
    end
  end

end
