require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "/copies", type: :request do
  let!(:book) { create :book }
  let!(:copies) { create_list :copy, 5, book_id: book.id }
  let!(:a_reader) { create :user, :as_reader }
  let(:reader_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_reader) }
  let!(:a_liber) { create :user, :as_librarian }
  let(:liber_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_liber) }
  let(:valid_attrs) { {} }
  let(:invalid_attrs) { {} }

  describe "GET /index" do
    before { get "/books/#{book.id}/copies/" }
    it "get all copies" do
      expect(response).to be_successful
      expect(json.size).to eq(5)
    end
  end

  describe "GET /show" do
    before { get "/copies/#{copy_id}" }

    context "vaild copy_id" do
      let(:copy_id) { copies.first.id }
      it "return book data'" do
        expect(response).to be_successful
        expect(json["id"]).to eq(copy_id)
      end
    end

    context "invaild copy_id" do
      let(:copy_id) { copies[-1].id+1 }

      it "return error msg" do
        expect(response).to have_http_status(404)
        expect(json["msg"]).to match('not found')
      end
    end
  end

  describe "POST /create" do
    context 'is librarian' do
      context "with valid parameters" do
        before { post "/books/#{book.id}/copies/", headers: liber_header, params: valid_attrs }

        it 'return created copy' do
          expect(json["id"]).to eq(copies.size+1)
        end
      end

      context "with invalid parameters" do
        it 'return invalid error msg'
      end
    end

    context 'not librarian' do
      before { post "/books/#{book.id}/copies/", headers: reader_header, params: valid_attrs }
      
      it 'reject create a copy' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /update" do
    
    context 'is librarian' do
      before { patch "/copies/#{copy_id}", headers: liber_header, params: valid_attrs }

      context "with valid copy_id" do
        context "with valid parameters" do
          it 'return updated book'
        end

        context "with invalid parameters" do
          it 'return invalid error msg'
        end
      end

      context "with invalid copy_id" do
        let(:copy_id) { copies[-1].id+1 }
        it 'return invalid error msg' do
          expect(response).to have_http_status(404)
          expect(json["msg"]).to match('not found')
        end
      end
    end

    context 'not librarian' do
      before { patch "/copies/1", headers: reader_header, params: valid_attrs }
      
      it 'reject create a book' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "DELETE /destroy" do
    context 'is librarian' do
      before { delete "/copies/#{copy_id}", headers: liber_header, params: valid_attrs }

      context "with valid copy_id" do
        let(:copy_id) { 1 }
        it 'return success msg' do
          p json
          expect(json["msg"]).to match("#{copy_id} has been deleted")
        end
      end

      context "with invalid copy_id" do
        let(:copy_id) { copies[-1].id+1 }
        it 'return invalid error msg' do
          expect(response).to have_http_status(404)
          expect(json["msg"]).to match('not found')
        end
      end
    end

    context 'not librarian' do
      before { delete "/books/1", headers: reader_header, params: valid_attrs }
      
      it 'reject create a book' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /read_book" do
    let!(:copy) { create :copy }
    before { patch "/copies/#{copy.id}/read_book" }
    it "copy state should be read_by_someone" do
      expect(response).to be_successful
      expect(json["id"]).to eq(copy.id)
      expect(json["copy_state"]).to eq("read_by_someone")
    end
  end

  describe "PATCH /put_it_back" do
    let!(:copy) { create :copy, :read_by_someone }
    before { patch "/copies/#{copy.id}/put_it_back" }
    it "copy state should be on_shelf" do
      p json
      expect(response).to be_successful
      expect(json["id"]).to eq(copy.id)
      expect(json["copy_state"]).to eq("on_shelf")
    end
  end
end
