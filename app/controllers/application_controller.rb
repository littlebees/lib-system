class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  rescue_from CanCan::AccessDenied do |e|
    render json: { data: {}, msg: e.message  }, status: 401
  end

  rescue_from AASM::InvalidTransition do |e|
    render json: { data: {}, msg: "Cant #{e.event_name} when this book is #{e.originating_state}" }, status: 409
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { data: {}, msg: "not found" }, status: 404
  end
  # https://github.com/waiting-for-dev/devise-jwt/wiki/Configuring-devise-for-APIs
end
