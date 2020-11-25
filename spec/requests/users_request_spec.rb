require 'rails_helper'

RSpec.describe "Users", type: :request do

  describe "GET /login" do
    it "returns http success" do
      get "/users/login"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /logout" do
    it "returns http success" do
      get "/users/logout"
      expect(response).to have_http_status(:success)
    end
  end

end
