class Reservation < Ticket
  def self.current_active_reservation(copy_id)
    pending.where(:copy => copy_id).order(:created_at => :asc).limit(1)[0]
  end
  def set_due_date
    self.due_date = DateTime.now + 30
  end
end
