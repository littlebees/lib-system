class CopiesController < ApplicationController
  before_action :set_copy, only: [:show, :update, :destroy]
  # GET /copies
  def index
    @copies = Copy.all

    render json: @copies
  end

  # GET /copies/1
  def show
    render json: @copy
  end

  # POST /copies
  def create
    @copy = Copy.new(copy_params)

    if @copy.save
      render json: @copy, status: :created, location: @copy
    else
      render json: @copy.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /copies/1
  def update
    if @copy.update(copy_params)
      render json: @copy
    else
      render json: @copy.errors, status: :unprocessable_entity
    end
  end

  # DELETE /copies/1
  def destroy
    @copy.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_copy
      @copy = Copy.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def copy_params
      params.fetch(:copy, {})
    end
end
