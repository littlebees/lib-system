# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
    before_action :authenticate_user!
end
