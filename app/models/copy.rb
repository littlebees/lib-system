class Copy < ApplicationRecord
  include AASM
  my_method = self.method(:method)
  # TODO: add rollback whene after
  belongs_to :book
  has_many :tickets

  aasm column: 'copy_state' do
    state :on_shelf, inital: true
    state :read_by_someone, :reserved
    state :waiting_for_approvment, :returning
    state :lent, :lost, :over_due
    state :waiting_to_be_classified

    event :take_this_book do
      transitions from: :on_shelf, to: :read_by_someone
    end

    event :put_it_back_to_shelf do
      transitions from: :read_by_someone, to: :on_shelf
    end

    # args[:reader]
    event :borrow_this_book do
      transitions from: [:on_shelf, :read_by_someone], to: :waiting_for_approvment
      after ->(args={}) { self.borrow_this_book_after_cb(args) }
    end
    # args[:reader]
    event :take_reserved_book, guards:[:can_take_this_reserved_book] do
      transitions from: :reserved, to: :waiting_for_approvment
      after ->(args={}) { self.take_reserved_book_after_cb(args) }
    end
    # args[:reader]
    event :lend_this_book do
      transitions from: :waiting_for_approvment, to: :lent
      after ->(args={}) { self.lend_this_book_after_cb(args) }
    end

    event :mark_over_due do
      transitions from: :lent, to: :over_due
      after ->(args={}) { self.mark_over_due_after_cb(args) }
    end

    event :mark_lost do
      transitions from: [:on_shelf, :lent, :over_due], to: :lost
      after ->(args={}) { self.mark_lost_after_cb(args) }
    end

    event :return_this_book do
      transitions from: [:lent, :over_due], to: :returning
    end

    event :get_lent_book do
      transitions from: :returning, to: :waiting_to_be_classified
      after ->(args={}) { self.get_lent_book_after_cb(args) }
    end

    event :put_this_book_onto_shelf do
      transitions from: :waiting_to_be_classified, to: :on_shelf
    end

    event :keep_for_reservation do
      transitions from: :waiting_to_be_classified, to: :reserved
      after ->(args={}) { self.keep_for_reservation_after_cb(args) }
    end
  end
  
private
  def can_take_this_reserved_book(args={})
    !args.empty? and Reservation.current_active_reservation(self).reader == args[:reader]
  end
  
  def borrow_this_book_after_cb(args)
    Lending.create! copy: self, reader: args[:reader]
  end

  def get_lent_book_after_cb(args)
    t = tickets.approved.first
    t.get_lent_book!
  end

  def keep_for_reservation_after_cb(args)
    args[:copy] = self
    t = Reservation.current_active_reservation(self)
    t.reader.inform_reservation_book_arrived(args)
  end

  def mark_lost_after_cb(args)
    wtf = tickets.approved.where(:type => "Lending").includes(:reader).first
    args[:copy] = self
    wtf.reader.lost_cb(args) if wtf

    ts = tickets
    ts.each do |t|
      t.archive!
    end
  end

  def mark_over_due_after_cb(args)
    t = tickets.approved.where(:type => "Lending").includes(:reader).first
    args[:copy] = self
    t.reader.over_due_cb(args)
  end

  def take_reserved_book_after_cb(args)
    t = Reservation.current_active_reservation(self)
    t.type = "Lending"
    t.approve!
  end

  def lend_this_book_after_cb(args)
    t = Lending.pending.where(copy: self).where(reader: args[:reader]).first
    t.approve!
  end
end
