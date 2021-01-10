class LibrariansController < ApplicationController
  #TODO: paging
  before_action :authenticate_user!
  before_action :set_reader, only: [:lend_this_book]
  # fucking importtant , parent: false, if you want to use :copy to authorize
  load_and_authorize_resource :copy, id_param: :copy_id, parent: false, only: [:get_lent_book, :lend_this_book]
  # https://github.com/ryanb/cancan/blob/master/lib/cancan/controller_additions.rb

  def show
    authorize! :show, :librarian
    tickets = Ticket.all
    render json: { data: tickets }
  end

  def get_lent_book
    @copy.get_lent_book!
    render json: { data: @copy }
  end

  def lend_this_book
    #authorize! :lend_this_book, @copy
    @copy.lend_this_book! reader: @reader
    render json: { data: @copy }
  end

  def classify_books
    #TODO
    #1. back to shelf
    #2. inform reservation
  end
private
  def set_reader
    @reader = Reader.find(params[:reader_id])
  end
end