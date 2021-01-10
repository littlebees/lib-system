class BooksController < ApplicationController
  load_and_authorize_resource

  # GET /books
  def index
    render json: { data: @books }
  end

  # GET /books/1
  def show
    render json: { data: @book }
  end

  # POST /books
  def create
    @book = Book.new(book_params)

    if @book.save
      render json: { data: @book }, status: 201, location: @book
    else
      render json: { msg: @book.errors }, status: 503
    end
  end

  # PATCH/PUT /books/1
  def update
    if @book.update(book_params)
      render json: { data: @book }
    else
      render json: { msg: @book.errors }, status: 503
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
    render json: { msg: "#{params[:id]} has been deleted"}
  end

  private
    # Only allow a trusted parameter "white list" through.
    def book_params
      params.fetch(:book, {})
    end
end
