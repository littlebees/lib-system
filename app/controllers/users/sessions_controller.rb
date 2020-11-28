# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  #before_action :authenticate_user!
  #load_and_authorize_resource :user, through: :current_user
  
  private
  def respond_with(resource, _opts = {})
    render json: {user: resource, token: current_token}
  end
  def respond_to_on_destroy
    head :no_content
  end
  def current_token
    request.env["warden-jwt_auth.token"]
  end
end
