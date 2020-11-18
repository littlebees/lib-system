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
        it "allow event: take_this_book, borrow_this_book"
        it "allow transition to: read_by_someone, waiting_for_approvment, lost"
      end

      context "read_by_someone" do
        it "allow event: put_it_back_to_shelf, borrow_this_book"
        it "allow transition to: on_shelf, waiting_for_approvment"
      end

      context "reserved" do
        it "allow event: take_reserved_book"
        it "allow transition to: waiting_for_approvment"
      end

      context "waiting_for_approvment" do
        it "allow event: lend_this_book"
        it "allow transition to: lent"
      end

      context "lent" do
        it "allow event: mark_over_due, mark_lost, get_lent_book"
        it "allow transition to: over_due, lost, waiting_to_be_classified"
      end

      context "waiting_to_be_classified" do
        it "allow event: put_this_book_onto_shelf, keep_for_reservation"
        it "allow transition to: on_shelf, reserved"
      end

      context "over_due" do
        it "allow event: get_lent_book, mark_lost"
        it "allow transition to: waiting_for_approvment, lost"
      end

      context "lost" do
        it "sink state"
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
