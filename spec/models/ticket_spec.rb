require 'rails_helper'


RSpec.describe Ticket, type: :model do
  describe "association" do
    it { should belong_to(:reader) }
    it { should belong_to(:copy) }
  end

  describe "ticket state" do
    it "should start from Pending state" do
      t = Ticket.new
      expect(t).to have_state(:pending)
    end
    describe "state" do
      context "Pending" do
        subject { Ticket.new }

        include_examples "all allowed events", [:approve]

        include_examples "all allowed states", [:approved]
      end

      context "Approved" do
        subject { Ticket.new ticket_state: "approved" }
        
        include_examples "all allowed events", [:archive, :get_lent_book]

        include_examples "all allowed states", [:recording]
      end

      context "Recording" do
        subject { Ticket.new ticket_state: "recording" }

        # if i only use expect(subject).to allow_event
        # i cant test this case!!
        include_examples "all allowed events", []

        include_examples "all allowed states", []
      end
    end

    describe "event" do
      context "approve" do
        before(:each) { @t = Ticket.new ticket_state: "pending" }
        it "change state: pending => approved" do
          allow(@t).to receive(:set_due_date)
          expect(@t).to transition_from(:pending).to(:approved).on_event(:approve)
        end
        it "set due date" do
          now = DateTime.now
          allow(@t).to receive(:set_due_date) { @t.due_date = now }
          @t.approve
          expect(@t.due_date).to eq(now)
        end
      end

      context "archive" do
        before(:each) { @t = Ticket.new ticket_state: "approved" }
        it "change state: [approved, pending] => recording" do
          expect(@t).to transition_from(:approved).to(:recording).on_event(:archive)
          expect(@t).to transition_from(:pending).to(:recording).on_event(:archive)
        end
      end

      context "get_lent_book" do
        before(:each) { @t = Ticket.new ticket_state: "approved" }
        it "change state: approved => recording" do
          expect(@t).to transition_from(:approved).to(:recording).on_event(:get_lent_book)
        end
        it "set return date" do
          @t.get_lent_book
          expect(@t.return_date).not_to be_falsey
        end
      end
    end
  end

  describe "instance method" do
    # set_due_date
    it "set_due_date should be implemented by child class" do
      t = Ticket.new
      expect { t.set_due_date }.to raise_error(NotImplementedError)
    end
    # set_return_date
    it "set_return_date should set return_date" do
      t = Ticket.new
      t.set_return_date
      expect(t.return_date).not_to be_falsey
    end
  end
end
