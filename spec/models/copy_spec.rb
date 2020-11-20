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
        subject { Copy.new copy_state: "reserved" }
        
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
