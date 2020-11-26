class Ticket < ApplicationRecord
  include AASM
  belongs_to :reader
  belongs_to :copy

  aasm column: 'ticket_state' do
    state :pending, inital: true
    state :approved
    state :recording

    event :approve do
      after do 
        set_due_date
        self.save
      end
      transitions from: :pending, to: :approved
    end

    event :archive do
      transitions from: [:approved, :pending], to: :recording
    end

    event :get_lent_book do
      after do
        set_return_date
        self.save
      end
      transitions from: :approved, to: :recording
    end
  end

private
  def set_due_date
    fail NotImplementedError, "subclass should implement this method!"
  end

  def set_return_date
    self.return_date = DateTime.now
  end
end
