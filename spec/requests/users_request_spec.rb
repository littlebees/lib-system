require 'rails_helper'
require 'devise/jwt/test_helpers'

RSpec.describe "Users", type: :request do
  let!(:user) { create :user }
  let(:base_header) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }
  let(:header) { Devise::JWT::TestHelpers.auth_headers(base_header, user) }
  describe "POST /sign_in" do
    context "valid account" do
      before { post "/sign_in", params: { user: { email: user.email, password: user.password } }, as: :json}
      it "returns http success" do
        expect(json["token"]).not_to be_empty
      end
    end

    context "wrong password" do
      before { post "/sign_in", params: { user: { email: user.email, password: user.password+"123" } }, as: :json}
      it "returns http success" do
        expect(json["msg"]).to match('Invalid Email or password.')
      end
    end

    context "invalid account" do
      before { post "/sign_in", params: { user: { email: user.email+"123", password: user.password } }, as: :json}
      it "returns http success" do
        expect(json["msg"]).to match('Invalid Email or password.')
      end
    end
  end

  describe "DELETE /sign_out" do
    before { delete "/sign_out", headers: header }
    it "returns http success" do
      expect(json["msg"]).to match("successfully signed out")
    end
  end
end
