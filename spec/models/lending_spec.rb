require 'rails_helper'

RSpec.describe Lending, type: :model do
  describe "instance method" do
    it "set_due_date: due_date > today" do
       l = Lending.new
       l.set_due_date
       except(l.due_date).to be > DateTime.now
    end
  end
end
