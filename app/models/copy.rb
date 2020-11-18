class Copy < ApplicationRecord
  include AASM
  belongs_to :book
  has_many :tickets

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
      after do |args|
        # generate a ticket
        t = Lending.create copy: args[:copy], reader: args[:reader]
      end
      transitions from: [:on_shelf, :read_by_someone], to: :waiting_for_approvment
    end

    event :take_reserved_book do
      after do |args|
        t = Reservation.current_active_reservation
        t.type = "Lending"
        t.approve
      end
      transitions from: :reserved, to: :waiting_for_approvment, gurad: ->(args) do
        Reservation.where(:copy => id).where(:reader => args[:reader].id).first == Reservation.current_active_reservation
      end
    end

    event :lend_this_book do
      after do |args|
        t = Lending.pending.where(:copy => id).where(:reader => args[:reader].id).limit(1)[0]
        t.approve
      end
      transitions from: :waiting_for_approvment, to: :lent
    end

    event :mark_over_due do
      after do |args|
        t = tickets.approved.where(:type => "Lending").includes(:reader).limit(1)[0]
        t.reader.over_due_cb(:copy => self)
      end
      transitions from: :lent, to: :over_due
    end

    event :mark_lost do
      after do
        wtf = tickets.approved.where(:type => "Lending").includes(:reader).limit(1)[0]
        wtf.reader.lost_cb(:copy => self)

        ts = tickets.pending
        ts do |t|
          t.archive
        end
      end
      transitions from: [:on_shelf, :lent, :over_due], to: :lost
    end

    event :get_lent_book do
      after do
        t = Lending.approved.where(:copy => id).limit(1)[0]
        t.get_lent_book
      end
      transitions from: [:lent, :over_due], to: :waiting_to_be_classified
    end

    event :put_this_book_onto_shelf do
      transitions from: :waiting_to_be_classified, to: :on_shelf
    end

    event :keep_for_reservation do
      after do
        t = Reservation.current_active_reservation
        t.reader.inform_reservation_book_arrived(:copy => self)
      end
      transitions from: :waiting_to_be_classified, to: :reserved
    end
  end

end
