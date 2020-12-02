class ReadersController < ApplicationController
  before_action :authenticate_user!
  before_action :load_reader
  load_and_authorize_resource :copy, id_param: :copy_id, parent: false, only: [:borrow, :take_reserved, :return_it]

  def show
    authorize! :show,  @reader
    render json: @reader.tickets
  end

  def borrow
    @copy.borrow_this_book! reader: @reader
    render json: @copy
  end

  def take_reserved
    @copy.take_reserved_book! reader: @reader
    render json: @copy
  end

  def return_it
    @copy.return_this_book!
    render json: @copy
  end

private
  def load_reader
    @reader = current_user.role
  end
  def load_tickets
    @tickets = @reader.tickets
  end
end
