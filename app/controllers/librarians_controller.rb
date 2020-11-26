class LibrariansController < ApplicationController
  before_action :set_copy, only: [:get_lent_book, :lend_this_book]
  before_action :set_reader, only: [:lend_this_book]
  def get_lent_book
    @copy.get_lent_book!
    render json: @copy
  end

  def lend_this_book
    @copy.lend_this_book! reader: @reader
    render json: @copy
  end

  #TODO: paging
  def show
    tickets = Ticket.all
    render json: tickets
  end
private
    # Use callbacks to share common setup or constraints between actions.
    def set_copy
      @copy = Copy.find(params[:copy_id])
    end
    def set_reader
      @reader = Reader.find(params[:reader_id])
    end
end
