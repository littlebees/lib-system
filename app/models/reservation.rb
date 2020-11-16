class Reservation < Ticket
  scope :in_time, -> { where('due_date >= ?', DateTime.now)}
  scope :legal_reservations, -> { pending.in_time }
  def self.current_active_reservation(copy_id)
    legal_reservations.where(:copy => copy_id).order(:created_at => :asc).limit(1)[0]
  end
  def set_due_date
    due_date = DataTime.now.days_ago(30)
  end
end
