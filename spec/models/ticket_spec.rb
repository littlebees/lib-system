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
        subject! do
          Ticket.any_instance.stub(:set_due_date)
          Ticket.new
        end
        

        include_examples "all allowed events", [:approve, :archive]

        include_examples "all allowed states", [:approved, :recording]
      end

      context "Approved" do
        subject! do
          Ticket.new ticket_state: "approved"
        end
        
        include_examples "all allowed events", [:archive, :get_lent_book]

        include_examples "all allowed states", [:recording]
      end

      context "Recording" do
        subject! do
          Ticket.any_instance.stub(:set_return_date)
          Ticket.new ticket_state: "recording"
        end

        # if i only use @expect_event_in_Ticket allow_event
        # i cant test this case!!
        include_examples "all allowed events", []

        include_examples "all allowed states", []
      end
    end

    describe "event" do
      before do
        @expect_event_in_Ticket = expect_event Ticket
      end

      context "approve" do
        subject! { Ticket.create ticket_state: "pending" }

        it "change state: pending => approved" do
          Ticket.any_instance.stub(:set_due_date)
          @expect_event_in_Ticket[transition_from(:pending).to(:approved).on_event(:approve)]
        end

        it "set due date" do
          now = DateTime.now
          allow(subject).to receive(:set_due_date) { subject.due_date = now }
          subject.approve
          expect(subject.due_date).to eq(now)
        end
      end

      context "archive" do
        subject! { Ticket.new ticket_state: "approved" }

        it "change state: [approved, pending] => recording" do
          @expect_event_in_Ticket[transition_from(:approved).to(:recording).on_event(:archive)]
          @expect_event_in_Ticket[transition_from(:pending).to(:recording).on_event(:archive)]
        end
      end

      context "get_lent_book" do
        subject! { Ticket.new ticket_state: "approved" }

        it "change state: approved => recording" do
          Ticket.any_instance.stub(:set_return_date)
          @expect_event_in_Ticket[transition_from(:approved).to(:recording).on_event(:get_lent_book)]
        end

        it "set return date" do
          subject.get_lent_book
          expect(subject.return_date).not_to be_falsey
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
