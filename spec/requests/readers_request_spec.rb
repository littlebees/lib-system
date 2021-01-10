require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Readers", type: :request do
  let!(:a_reader) { create :user, :as_reader }
  let!(:b_reader) { create :user, :as_reader }
  let(:base_header) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
  let(:reader_header) { Devise::JWT::TestHelpers.auth_headers(base_header, a_reader) }
  let(:other_header) { Devise::JWT::TestHelpers.auth_headers(base_header, b_reader) }

  describe "GET /show" do
    let!(:tickets) { create_list :ticket, 5, reader_id: a_reader.id }
    before { get "/reader", headers: who }
    
    context 'is reader' do
        #let!(:tickets) { create_list :ticket, 5 } cant place this line in HERE!???
        let(:who) { reader_header }
        it 'return created copy' do
          expect(json["data"].size).to eq(tickets.size)
        end
    end

    context 'not reader' do
      let(:who) { base_header }
      it 'reject' do
        expect(json["msg"]).to match('You need to sign in or sign up before continuing')
      end
    end
  end

  describe "PATCH /take_reserved" do
    let!(:copy) { create :copy, :reserved }
    let!(:ticket) { create :ticket, :reservation, :pending, copy_id: copy.id, reader_id: a_reader.id }
    before { patch "/reader/take_reserved", headers: who, params: { copy_id: copy.id }, as: :json }
    
    context 'is librarian' do
      context "right applicant" do
        let(:who) { reader_header }
        it 'copy_state should be waiting_for_approvment' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("waiting_for_approvment")
        end
        it 'ticket_state should be recording' do
          #expect(ticket.ticket_state).to eq("recording")
          expect(Lending.approved.first.copy_id).to eq(copy.id)
        end
      end
      context "not right applicant" do
        let(:who) { other_header }
        it 'reject' do
          expect(json["msg"]).to match('Cant take_reserved_book when this book is reserved')
        end
      end
    end

    context 'not reader' do
      let(:who) { base_header }
      it 'reject' do
        expect(json["msg"]).to match('You need to sign in or sign up before continuing')
      end
    end
  end

  describe "PATCH /borrow" do
    let!(:copy) { create :copy }
    #let!(:ticket) { create :ticket, :lending, :pending, copy_id: copy.id, reader_id: a_reader.id }
    before { patch "/reader/borrow", headers: who, params: { copy_id: copy.id, reader_id: a_reader.id }, as: :json }
    
    context 'is reader' do
        let(:who) { reader_header }
        it 'copy_state should be waiting_for_approvment' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("waiting_for_approvment")
        end
        it 'ticket_state should be approved' do
          #expect(ticket.ticket_state).to eq("approved")
          t = Lending.pending.first
          expect(t.copy_id).to eq(copy.id)
          expect(t.reader_id).to eq(a_reader.id)
        end
    end

    context 'not reader' do
      let(:who) { base_header }
      it 'reject' do
        expect(json["msg"]).to match('You need to sign in or sign up before continuing')
      end
    end
  end
end
