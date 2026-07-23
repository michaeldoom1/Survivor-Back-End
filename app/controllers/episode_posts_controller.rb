class EpisodePostsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :create, :update, :destroy ]
  before_action :set_episode_post, only: [ :show, :update, :destroy ]

  def index
    season_id = params.require(:season_id)
    render json: EpisodePost.where(season_id: season_id).includes(:memes)
  end

  def show
    render json: @episode_post
  end

  def create
    episode_post = EpisodePost.new(episode_post_params)
    if episode_post.save
      render json: episode_post, status: :created
    else
      render json: { errors: episode_post.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @episode_post.update(episode_post_params)
      render json: @episode_post
    else
      render json: { errors: @episode_post.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @episode_post.destroy
    head :no_content
  end

  private

  def set_episode_post
    @episode_post = EpisodePost.includes(:memes).find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def episode_post_params
    params.require(:episode_post).permit(:season_id, :episode_number, :recap, :superlatives)
  end
end
