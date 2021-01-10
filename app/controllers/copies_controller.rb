class CopiesController < ApplicationController
  load_and_authorize_resource
  
  # GET /copies
  def index
    #@copies = Copy.all

    render json: { data: @copies }
  end

  # GET /copies/1
  def show
    render json: { data: @copy }
  end

  # POST /copies
  def create
    #@copy = Copy.new(copy_params)
    @copy.book_id = params[:book_id]
    if @copy.save
      render json: { data: @copy }, status: 201, location: @copy
    else
      render json: { msg: @copy.errors }, status: 503
    end
  end

  # PATCH/PUT /copies/1
  def update
    if @copy.update(copy_params)
      render json: { data: @copy }
    else
      render json: { msg: @copy.errors }, status: 503
    end
  end

  # DELETE /copies/1
  def destroy
    @copy.destroy
    render json: { msg: "#{params[:id]} has been deleted" }
  end

  def read_book
    @copy.take_this_book!
    render json: { data: @copy }
  end

  def put_it_back
    @copy.put_it_back_to_shelf!
    render json: { data: @copy }
  end

  private
    # Only allow a trusted parameter "white list" through.
    def copy_params
      params.fetch(:copy, {})
    end
end
