class Reader < ApplicationRecord
  has_one :user, as: :role, dependent: :destroy
  has_many :tickets
  has_many :copies, through: :tickets

  def over_due_cb(args)
    # args[:copy]
    args[:debug] = :reached
  end
  def lost_cb(args)
    # args[:copy]
    args[:debug] = :reached
  end
  def inform_reservation_book_arrived(args)
    # args[:copy]
    args[:debug] = :reached
  end
end
