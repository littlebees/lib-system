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
        before(:each) { @t = Ticket.new }
        
        it "allow event: approve" do
          expect(@t).to allow_event(:approve)
        end

        it "allow transition to: approved" do
          expect(@t).to allow_transition_to(:approved)
        end
      end

      context "Approved" do
        before(:each) { @t = Ticket.new ticket_state: "approved" }
        
        it "allow event: achrive, get_lent_book" do
          expect(@t).to allow_event(:archive)
          expect(@t).to allow_event(:get_lent_book)
        end

        it "allow transition to: recording" do
          expect(@t).to allow_transition_to(:recording)
        end
      end

      context "Recording" do
        before(:each) { @t = Ticket.new ticket_state: "recording" }

        it "sink state" do
          expect(@t).not_to allow_transition_to(:recording)
          expect(@t).not_to allow_transition_to(:approved)
          expect(@t).not_to allow_transition_to(:pending)
        end
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
        it "change state: approved => recording" do
          expect(@t).to transition_from(:approved).to(:recording).on_event(:archive)
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
