class EpisodeScoresController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [:create, :update, :destroy]
  before_action :set_episode_score, only: [:show, :update, :destroy]

  def index
    render json: EpisodeScore.all
  end

  def show
    render json: @episode_score
  end

  def create
    episode_score = EpisodeScore.new(episode_score_params)
    if episode_score.save
      render json: episode_score, status: :created
    else
      render json: { errors: episode_score.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @episode_score.update(episode_score_params)
      render json: @episode_score
    else
      render json: { errors: @episode_score.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @episode_score.destroy
    head :no_content
  end

  private

  def set_episode_score
    @episode_score = EpisodeScore.find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def episode_score_params
    params.require(:episode_score).permit(:contestant_id, :scoring_event_id, :episode_number, :season_id)
  end
end
