class Lending < Ticket
  def set_due_date
    due_date = DataTime.now.days_ago(30)
  end

end
