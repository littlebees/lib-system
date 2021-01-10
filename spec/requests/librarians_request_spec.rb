require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Librarians", type: :request do
  let!(:a_reader) { create :user, :as_reader }
  let(:reader_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_reader) }
  let!(:a_liber) { create :user, :as_librarian }
  let(:liber_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_liber) }
  describe "GET /show" do
    let!(:tickets) { create_list :ticket, 5 }
    before { get "/librarian", headers: who }
    
    context 'is librarian' do
        #let!(:tickets) { create_list :ticket, 5 } cant place this line in HERE!???
        let(:who) { liber_header }
        it 'return created copy' do
          expect(json["data"].size).to eq(tickets.size)
        end
    end

    context 'not librarian' do
      let(:who) { reader_header }
      it 'reject' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /get_lent_book" do
    let!(:copy) { create :copy, :returning }
    let!(:ticket) { create :ticket, :lending, :approved, copy_id: copy.id }
    before { patch "/librarian/get_lent_book?", headers: who, params: { copy_id: copy.id }, as: :json }
    
    context 'is librarian' do
        let(:who) { liber_header }
        it 'copy_state should be waiting_to_be_classified' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("waiting_to_be_classified")
        end
        it 'ticket_state should be recording' do
          #expect(ticket.ticket_state).to eq("recording")
          expect(Lending.recording.first.copy_id).to eq(copy.id)
        end
    end

    context 'not librarian' do
      let(:who) { reader_header }
      it 'reject' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /lend_this_book" do
    let!(:copy) { create :copy, :waiting_for_approvment }
    let!(:ticket) { create :ticket, :lending, :pending, copy_id: copy.id, reader_id: a_reader.id }
    before { patch "/librarian/lend_this_book?", headers: who, params: { copy_id: copy.id, reader_id: a_reader.id }, as: :json }
    
    context 'is librarian' do
        let(:who) { liber_header }
        it 'copy_state should be lent' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("lent")
        end
        it 'ticket_state should be approved' do
          #expect(ticket.ticket_state).to eq("approved")
          expect(Lending.approved.first.copy_id).to eq(copy.id)
        end
    end

    context 'not librarian' do
      let(:who) { reader_header }
      it 'reject' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /classify_books" do
    before { patch "/librarian/classify_books?", headers: who, params: { copy_id: copy.id }, as: :json }
    
    context 'is librarian' do
        let(:who) { liber_header }
        context 'book is not reserved' do
          it 'back to shelf'
        end
        context 'book is reserved' do
          it 'inform reservation'
        end
        
    end

    context 'not librarian' do
      let(:who) { reader_header }
      xit 'reject' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end
end
