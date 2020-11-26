class ReadersController < ApplicationController
  before_action :set_copy, only: [:read, :reserve, :borrow, :show, :take_reserved, :return_it]
  before_action :set_reader, only: [:borrow, :take_reserved, :tickets]

  def show
    tickets = @reader.tickets
    render json: tickets
  end

  def read
    @copy.take_this_book!
    render json: @copy
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

  def tickets
    render json: @reader.tickets
  end
private
    # Use callbacks to share common setup or constraints between actions.
    def set_copy
      @copy = Copy.find(params[:copy_id])
    end
    def set_reader
      @reader = Reader.find(params[:id])
    end
end
