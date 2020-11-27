class UsersController < Devise::SessionsController
  def create
    render json: { user: current_user, token: current_token }
  end

  private

  def current_token
    p request.env["warden-jwt_auth.token"]
    request.env["warden-jwt_auth.token"]
  end
end
