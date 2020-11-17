require 'rails_helper'

RSpec.describe Lending, type: :model do
  describe "instance method" do
    it "set_due_date: due_date > today" do
       b = Book.create
       c = Copy.create book: b
       r = Reader.create
       l = Lending.new copy: c, reader: r
       l.set_due_date
       expect(l.due_date.utc).to be > DateTime.now.utc
    end
  end
end
