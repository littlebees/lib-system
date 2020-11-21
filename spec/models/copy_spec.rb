require 'rails_helper'


RSpec.describe Copy, type: :model do
  describe "association" do
    it { should belong_to(:book) }
    it { should have_many(:tickets) }
  end

  describe "copy state" do
    it "should start from on_shelf state" do
      t = Copy.new
      expect(t).to have_state(:on_shelf)
    end

    describe "state" do
      context "on_shelf" do
        subject { Copy.new copy_state: "on_shelf" }
        
        include_examples "all allowed events", [:take_this_book, :borrow_this_book, :mark_lost]
        
        include_examples "all allowed states", [:read_by_someone, :waiting_for_approvment, :lost]
      end

      context "read_by_someone" do
        subject { Copy.new copy_state: "read_by_someone" }

        include_examples "all allowed events", [:put_it_back_to_shelf, :borrow_this_book]

        include_examples "all allowed states", [:waiting_for_approvment, :on_shelf]
      end

      context "reserved" do
        subject! do
          Copy.any_instance.stub(:can_take_this_reserved_book).and_return(true)
          c = Copy.new copy_state: "reserved"
          c
        end
        
        include_examples "all allowed events", [:take_reserved_book]

        include_examples "all allowed states", [:waiting_for_approvment]
      end

      context "waiting_for_approvment" do
        subject { Copy.new copy_state: "waiting_for_approvment" }

        include_examples "all allowed events", [:lend_this_book]

        include_examples "all allowed states", [:lent]
      end

      context "lent" do
        subject { Copy.new copy_state: "lent" }

        include_examples "all allowed events", [:mark_lost, :mark_over_due, :get_lent_book]

        include_examples "all allowed states", [:lost, :waiting_to_be_classified, :over_due]
      end

      context "waiting_to_be_classified" do
        subject { Copy.new copy_state: "waiting_to_be_classified" }

        include_examples "all allowed events", [:keep_for_reservation, :put_this_book_onto_shelf]

        include_examples "all allowed states", [:on_shelf, :reserved]
      end

      context "over_due" do
        subject { Copy.new copy_state: "over_due" }

        include_examples "all allowed events", [:mark_lost, :get_lent_book]

        include_examples "all allowed states", [:lost, :waiting_to_be_classified]
      end

      context "lost" do
        subject { Copy.new copy_state: "lost" }

        include_examples "all allowed events", []

        include_examples "all allowed states", []
      end
    end

    describe "event" do
      before do
        @b = Book.create
        @r = Reader.create
        @expect_event_in_Copy = expect_event Copy
      end
      context "take_this_book" do
        subject { Copy.new copy_state: "on_shelf" }

        it "change state: on_shelf => read_by_someone" do
          @expect_event_in_Copy[transition_from(:on_shelf).to(:read_by_someone).on_event(:take_this_book)]
        end
      end

      context "put_it_back_to_shelf" do
        subject { Copy.new copy_state: "read_by_someone" }
        
        it "change state: read_by_someone => on_shelf" do
          @expect_event_in_Copy[transition_from(:read_by_someone).to(:on_shelf).on_event(:put_it_back_to_shelf)]
        end
      end

      context "borrow_this_book" do
        subject! do
          # create model goese with let! or subject!
          c = Copy.create! book: @b
          c.borrow_this_book(reader: @r)
          c
        end

        it "change state: [on_shelf, read_by_someone] => waiting_for_approvment" do
          Copy.any_instance.stub(:borrow_this_book_after_cb)
          @expect_event_in_Copy[transition_from(:on_shelf).to(:waiting_for_approvment).on_event(:borrow_this_book, reader: @r)]
          @expect_event_in_Copy[transition_from(:read_by_someone).to(:waiting_for_approvment).on_event(:borrow_this_book, reader: @r)]
        end
	      it "generate Lending ticket" do
          t = subject.tickets.pending.where(reader: @r).first
          expect(t).not_to be_nil
          expect(t).to have_state(:pending)
        end
      end

      context "take_reserved_book" do
        context "invalid reader" do
          subject! do
            c = Copy.create copy_state: "reserved", book: @b
            t = Reservation.create copy: c, reader: Reader.create
            c
          end
          it "should fail" do
            expect { subject.take_reserved_book(reader: @r) }.to raise_error(AASM::InvalidTransition)
          end
        end
        context "valid reader" do
          subject! do
            c = Copy.create copy_state: "reserved", book: @b
            t = Reservation.create copy: c, reader: @r
            c.take_reserved_book(reader: @r)
            c
          end
          it "change state: reserved => waiting_for_approvment" do
            Copy.any_instance.stub(:take_reserved_book_after_cb)
            Copy.any_instance.stub(:can_take_this_reserved_book).and_return(true)
            @expect_event_in_Copy[transition_from(:reserved).to(:waiting_for_approvment).on_event(:take_reserved_book, reader: @r)]
          end
          it "change reservation into lending" do
            t = subject.tickets.where(reader: @r).first
            expect(t).not_to be_nil
            expect(t).to have_state(:approved)
            expect(t.type).to eq("Lending")
          end
        end
      end

      context "lend_this_book" do
        subject! do
          c = Copy.create copy_state: "waiting_for_approvment", book: @b
          t = Lending.create copy: c, reader: @r
          c.lend_this_book(reader: @r)
          c
        end

        it "change state: waiting_for_approvment => lent" do
          Copy.any_instance.stub(:lend_this_book_after_cb)
          @expect_event_in_Copy[transition_from(:waiting_for_approvment).to(:lent).on_event(:lend_this_book, reader: @r)]
        end
	      it "ticket state should be aprroved" do
          t = subject.tickets.where(reader: @r).first
          expect(t).not_to be_nil
          expect(t).to have_state("approved")
        end
      end

      context "mark_over_due" do
        subject! do
          @args = {debug: true}
          c = Copy.create copy_state: "lent", book: @b
          t = Lending.create copy: c, reader: @r, ticket_state: "approved"
          c.mark_over_due(@args)
          c
        end
        
	      it "should invoke reader's over_due_cb" do
          # cant stub @r's method
          expect(@args[:debug]).to eq(:reached)
        end

        it "change state: lent => over_due" do
          #TODO: subject.stub(:mark_over_due_after_cb)
          Copy.any_instance.stub(:mark_over_due_after_cb)
          @expect_event_in_Copy[transition_from(:lent).to(:over_due).on_event(:mark_over_due, {})]
        end

      end

      context "mark_lost" do
        subject! do
          @args = {:debug => :noop}
          c = Copy.create copy_state: "lent", book: @b
          t = Lending.create copy: c, reader: @r, ticket_state: "approved"
          Reservation.create copy: c, reader: Reader.create
          c.mark_lost(@args)
          c
        end
        it "change state: [lent, over_due, on_shelf] => lost" do
          @expect_event_in_Copy[transition_from(:lent).to(:lost).on_event(:mark_lost,{})]
          @expect_event_in_Copy[transition_from(:over_due).to(:lost).on_event(:mark_lost,{})]
          @expect_event_in_Copy[transition_from(:on_shelf).to(:lost).on_event(:mark_lost,{})]
        end
        context "user unavaliable" do
          subject do
            args = {debug: :noop}
            c = Copy.create book: @b
            c.mark_lost(args)
            args
          end
	  it "should not invoke reader's lost_cb" do
            expect(subject[:debug]).not_to eq(:reached)
          end
        end

        context "user avaliable" do
	  it "should invoke reader's lost_cb" do
            expect(@args[:debug]).to eq(:reached)
          end
          it "should make all ticket into recording state" do
            expect(subject.tickets).not_to be_empty
            subject.tickets.each do |t|
              expect(t).to have_state(:recording)
            end
          end
        end
      end

      context "get_lent_book" do
        subject! do
          args = {}
          c = Copy.create copy_state: "lent", book: @b
          @t = Lending.create copy: c, reader: @r, ticket_state: "approved"
          c.get_lent_book(args)
          c
        end
        it "change state: [lent, over_due] => waiting_to_be_classified" do
          Copy.any_instance.stub(:get_lent_book_after_cb)
          @expect_event_in_Copy[transition_from(:lent).to(:waiting_to_be_classified).on_event(:get_lent_book,{})]
          @expect_event_in_Copy[transition_from(:over_due).to(:waiting_to_be_classified).on_event(:get_lent_book,{})]
        end
	it "ticket state should be recording" do
          t = subject.tickets.where(reader: @r).first
          expect(t).not_to be_nil
          expect(t).to eq(@t)
          expect(t).to have_state("recording")
        end
      end

      context "put_this_book_onto_shelf" do
        subject { Copy.new copy_state: "waiting_to_be_classified" }

        it "change state: waiting_to_be_classified => on_shelf" do
          @expect_event_in_Copy[transition_from(:waiting_to_be_classified).to(:on_shelf).on_event(:put_this_book_onto_shelf,{})]
        end
      end

      context "keep_for_reservation" do
        subject! do
          @args = {debug: :noop}
          c = Copy.create copy_state: "waiting_to_be_classified", book: @b
          t = Reservation.create copy: c, reader: @r
          c.keep_for_reservation(@args)
          c
        end
        it "change state: waiting_to_be_classified => reserved" do
          Copy.any_instance.stub(:keep_for_reservation_after_cb)
          @expect_event_in_Copy[transition_from(:waiting_to_be_classified).to(:reserved).on_event(:keep_for_reservation,{})]
        end
      	it "should inform reservation's owner" do
            expect(@args[:debug]).to eq(:reached)
        end
      end
    end
  end
end
