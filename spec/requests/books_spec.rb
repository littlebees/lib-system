require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "/books", type: :request do
  let!(:books) { create_list :book, 5 } # use BANG okay
  let!(:a_reader) { create :user, :as_reader }
  let(:reader_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_reader) }
  let!(:a_liber) { create :user, :as_librarian }
  let(:liber_header) { Devise::JWT::TestHelpers.auth_headers({ 'Accept' => 'application/json', 'Content-Type' => 'application/json' }, a_liber) }
  let(:valid_attrs) { {} }
  let(:invalid_attrs) { {} }

  describe "GET /index" do
    before { get "/books" }
    it "get all books" do
      expect(response).to be_successful
      expect(json.size).to eq(5)
    end
  end

  describe "GET /show" do
    before { get "/books/#{book_id}" }

    context "vaild book_id" do
      let(:book_id) { books.first.id }
      it "return book data'" do
        expect(response).to be_successful
        expect(json["id"]).to eq(book_id)
      end
    end

    context "invaild book_id" do
      let(:book_id) { books[-1].id+1 }

      it "return error msg" do
        expect(response).to have_http_status(404)
        expect(json["msg"]).to match('not found')
      end
    end
  end

  describe "POST /create" do
    context 'is librarian' do
      context "with valid parameters" do
        before { post "/books", headers: liber_header, params: valid_attrs }

        it 'return created book' do
          expect(json["id"]).to eq(books.size+1)
        end
      end

      context "with invalid parameters" do
        it 'return invalid error msg'
      end
    end

    context 'not librarian' do
      before { post "/books", headers: reader_header, params: valid_attrs }
      
      it 'reject create a book' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "PATCH /update" do
    
    context 'is librarian' do
      before { patch "/books/#{book_id}", headers: liber_header, params: valid_attrs }

      context "with valid book_id" do
        context "with valid parameters" do
          it 'return updated book'
        end

        context "with invalid parameters" do
          it 'return invalid error msg'
        end
      end

      context "with invalid book_id" do
        let(:book_id) { books[-1].id+1 }
        it 'return invalid error msg' do
          expect(response).to have_http_status(404)
          expect(json["msg"]).to match('not found')
        end
      end
    end

    context 'not librarian' do
      before { patch "/books/1", headers: reader_header, params: valid_attrs }
      
      it 'reject create a book' do
        expect(json["msg"]).to match('You are not authorized to access this page.')
      end
    end
  end

  describe "DELETE /destroy" do
    context 'is librarian' do
      before { delete "/books/#{book_id}", headers: liber_header, params: valid_attrs }

      context "with valid book_id" do
        let(:book_id) { 1 }
        it 'return success msg' do
          expect(json["msg"]).to match("#{book_id} has been deleted")
        end
      end

      context "with invalid book_id" do
        let(:book_id) { books[-1].id+1 }
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
end
