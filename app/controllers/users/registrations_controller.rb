# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
    before_action :authenticate_user!
    authorize_resource :signup, class: false
    def create
        build_resource(sign_up_params)

        resource.role = Reader.create

        resource.save
        render json: resource
    end
end
