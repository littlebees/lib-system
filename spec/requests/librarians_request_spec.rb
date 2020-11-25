require 'rails_helper'

RSpec.describe "Librarians", type: :request do

  describe "GET /get_lent_book" do
    it "returns http success" do
      get "/librarians/get_lent_book"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /lent_this_book" do
    it "returns http success" do
      get "/librarians/lent_this_book"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/librarians/show"
      expect(response).to have_http_status(:success)
    end
  end

end
