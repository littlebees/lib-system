class Reservation < Ticket
  def self.current_active_reservation(copy)
    Reservation.pending.where(copy: copy).order(:created_at => :asc).limit(1)[0]
  end
  def set_due_date
    self.due_date = DateTime.now + 30
  end
end
