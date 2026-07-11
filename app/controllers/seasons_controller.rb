class SeasonsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [:create, :update, :destroy]
  before_action :set_season, only: [:show, :update, :destroy]

  def index
    render json: Season.all
  end

  def show
    render json: @season
  end

  def create
    season = Season.new(season_params)
    if season.save
      render json: season, status: :created
    else
      render json: { errors: season.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @season.update(season_params)
      render json: @season
    else
      render json: { errors: @season.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    if @season.destroy
      head :no_content
    else
      render json: { errors: @season.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_season
    @season = Season.find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def season_params
    params.require(:season).permit(:number)
  end
end
