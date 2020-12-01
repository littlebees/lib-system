class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  rescue_from CanCan::AccessDenied do |e|
    render json: { status: false, msg: e.message  }
  end

  rescue_from AASM::InvalidTransition do |e|
    render json: { status: false, msg: "Cant #{e.event_name} when this book is #{e.originating_state}" }
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { status: false, msg: "not found" }, status: 404
  end
  # https://github.com/waiting-for-dev/devise-jwt/wiki/Configuring-devise-for-APIs
end
