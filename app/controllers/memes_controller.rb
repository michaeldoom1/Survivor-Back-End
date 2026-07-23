class MemesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def create
    meme = Meme.new(meme_params)
    if meme.save
      render json: meme, status: :created
    else
      render json: { errors: meme.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    meme = Meme.find(params[:id])
    meme.destroy
    head :no_content
  end

  private

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def meme_params
    params.require(:meme).permit(:episode_post_id, :image_url, :bluesky_url, :caption, :source_url)
  end
end
