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
        before do
          @c = Copy.new copy_state: "on_shelf"
        end
        it "allow event: take_this_book, borrow_this_book" do
          expect(@c).to allow_event(:take_this_book)
          expect(@c).to allow_event(:borrow_this_book)
        end
        it "allow transition to: read_by_someone, waiting_for_approvment, lost" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:read_by_someone, :waiting_for_approvment, :lost]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "read_by_someone" do
        before do
          @c = Copy.new copy_state: "read_by_someone"
        end
        it "allow event: put_it_back_to_shelf, borrow_this_book" do
          expect(@c).to allow_event(:put_it_back_to_shelf)
          expect(@c).to allow_event(:borrow_this_book)
        end
        it "allow transition to: on_shelf, waiting_for_approvment" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:waiting_for_approvment, :on_shelf]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "reserved" do
        before do
          @c = Copy.new copy_state: "reserved"
        end
        it "allow event: take_reserved_book" do
          expect(@c).to allow_event(:take_reserved_book)
        end
        it "allow transition to: waiting_for_approvment" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:waiting_for_approvment]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "waiting_for_approvment" do
        before do
          @c = Copy.new copy_state: "waiting_for_approvment"
        end
        it "allow event: lend_this_book" do
          expect(@c).to allow_event(:lend_this_book)
        end

        it "allow transition to: lent" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:lent]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "lent" do
        before do
          @c = Copy.new copy_state: "lent"
        end
        it "allow event: mark_over_due, mark_lost, get_lent_book" do
          expect(@c).to allow_event(:mark_over_due)
          expect(@c).to allow_event(:mark_lost)
          expect(@c).to allow_event(:get_lent_book)
        end
        it "allow transition to: over_due, lost, waiting_to_be_classified" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:lost, :waiting_to_be_classified, :over_due]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "waiting_to_be_classified" do
        before do
          @c = Copy.new copy_state: "waiting_to_be_classified"
        end
        it "allow event: put_this_book_onto_shelf, keep_for_reservation" do
          expect(@c).to allow_event(:put_this_book_onto_shelf)
          expect(@c).to allow_event(:keep_for_reservation)
        end
        it "allow transition to: on_shelf, reserved" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:on_shelf, :reserved]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "over_due" do
        before do
          @c = Copy.new copy_state: "over_due"
        end
        it "allow event: get_lent_book, mark_lost" do
          expect(@c).to allow_event(:get_lent_book)
          expect(@c).to allow_event(:mark_lost)
        end
        it "allow transition to: waiting_to_be_classified, lost" do
          all_states = @c.aasm.states.map(&:name)
          allow = [:lost, :waiting_to_be_classified]
          not_allow = all_states - allow
          allow.each { |s| expect(@c).to allow_transition_to(s) }
          not_allow.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end

      context "lost" do
        before do
          @c = Copy.new copy_state: "lost"
        end
        it "sink state" do
          all_states = @c.aasm.states.map(&:name)
          all_states.each { |s| expect(@c).not_to allow_transition_to(s) }
        end
      end
    end

    describe "event" do
      context "take_this_book" do
        it "change state: on_shelf => read_by_someone"
      end

      context "put_it_back_to_shelf" do
        it "change state: read_by_someone => on_shelf"
      end

      context "borrow_this_book" do
        it "change state: [read_by_someone, read_by_someone] => waiting_for_approvment"
	it "generate Lending ticket"
      end

      context "take_reserved_book" do
	it "fail when user is not reservation owner"
	it "change state: reserved => approved"
	it "change reservation into lending"
      end

      context "lend_this_book" do
        it "change state: waiting_for_approvment => lent"
	it "ticket state shoudl be aprroved"
      end

      context "mark_over_due" do
        it "change state: lent => over_due"
	it "should invoke reader's over_due_cb"
      end

      context "mark_lost" do
        it "change state: [lent, over_due, on_shelf] => recording"
	it "should invoke reader's lost_cb if user avaliable"
      end

      context "get_lent_book" do
        it "change state: [lent, over_due] => waiting_to_be_classified"
	it "ticket state should be recording"
      end

      context "put_this_book_onto_shelf" do
        it "change state: waiting_to_be_classified => on_shelf"
      end

      context "keep_for_reservation" do
        it "change state: waiting_to_be_classified => reserved"
	it "should inform reservation's owner"
      end
    end
  end
end
