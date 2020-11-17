class Lending < Ticket
  def set_due_date
    self.due_date = DateTime.now + 30
  end
end
