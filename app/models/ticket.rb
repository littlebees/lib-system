class Ticket < ApplicationRecord
  include AASM
  belongs_to :reader
  belongs_to :copy

  aasm column: 'ticket_state' do
    state :pending, inital: true
    state :lend_ticket, :reserve_ticket
    state :recording, :out_of_reserved_date

    event :lend_this_book do
      before do
        # set due_date
      end
      transitions from: :pending, to: :lend_ticket
    end

    event :reserve_this_book do
      before do
        # set due_date
      end
      transitions from: :pending, to: :reserve_ticket
    end

    event :get_lent_book do
      before do
        # set return date
      end
      transitions from: :lend_ticket, to: :recording
    end

    event :take_reserved_book do
      before do
        # set due_date
      end
      transitions from: :reserve_ticket, to: :lend_ticket
    end
  end
end
