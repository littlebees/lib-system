require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Readers", type: :request do
  let!(:reader) { create :user, :as_reader }
  let!(:someone) { create :user, :as_reader }
  let!(:base_header) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
  let!(:reader_header) { Devise::JWT::TestHelpers.auth_headers(base_header, reader) }
  let!(:someone_header) { Devise::JWT::TestHelpers.auth_headers(base_header, someone) }

  describe "GET /show" do
    let!(:tickets) { create_list :ticket, 5, reader_id: Reader.first.id } # why !!??
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
    let!(:ticket) { create :ticket, :reservation, :pending, copy_id: copy.id, reader_id: Reader.first.id } # weird, i cant use reader.id here
    before { patch "/reader/take_reserved", headers: who, params: { copy_id: copy.id }, as: :json }
    
    context 'is librarian' do
      context "right applicant" do
        let(:who) { reader_header }
        it 'copy_state should be waiting_for_approvment' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("waiting_for_approvment")
        end
        it 'ticket_state should be approved' do
          expect(Lending.approved.first.copy_id).to eq(copy.id)
        end
      end
      context "not right applicant" do
        let(:who) { someone_header }
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
    before { patch "/reader/borrow", headers: who, params: { copy_id: copy.id, reader_id: reader.id }, as: :json }
    
    context 'is reader' do
        let(:who) { reader_header }
        it 'copy_state should be waiting_for_approvment' do
          expect(json["data"]["id"]).to eq(copy.id)
          expect(json["data"]["copy_state"]).to eq("waiting_for_approvment")
        end
        it 'ticket_state should be pending' do
          t = Lending.pending.first
          expect(t.copy_id).to eq(copy.id)
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
