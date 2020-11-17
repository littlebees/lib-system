require 'rails_helper'

RSpec.describe Reservation, type: :model do
  describe "class method" do
    it ".current_active_reservation(copy_id)" do
      b = Book.create
      c = Copy.create book: b
      u = Reader.create
      r1 = Reservation.create copy: c, reader: u
      r2 = Reservation.create copy: c, reader: u
      r3 = Reservation.create copy: c, reader: u, ticket_state: "approved"
      r2.created_at = DateTime.now+1 # emulate later reservation
      r2.save

      expect(Reservation.current_active_reservation(c)).to eq(r1)
    end
  end

  describe "instance method" do
    it "set_due_date: due_date > today" do
      r = Reservation.new
      r.set_due_date
      expect(r.due_date).to be > DateTime.now
    end
  end
end
