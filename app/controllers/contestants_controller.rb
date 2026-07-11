class ContestantsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :create, :update, :destroy ]

  def index
    render json: Contestant.all
  end

  def scores
    season_id = params.require(:season_id)
    contestants = Contestant.where(season_id: season_id).includes(episode_scores: :scoring_event)

    render json: contestants.map { |contestant|
      {
        id: contestant.id,
        name: contestant.name,
        gender: contestant.gender,
        tribename: contestant.tribename,
        total_points: contestant.total_points,
        episode_scores: contestant.episode_scores.sort_by(&:episode_number).map { |episode_score|
          {
            id: episode_score.id,
            episode_number: episode_score.episode_number,
            scoring_event: episode_score.scoring_event.name,
            points: episode_score.points
          }
        }
      }
    }
  end

  def show
    contestant = Contestant.find(params[:id])
    render json: contestant
  end

  def create
    contestant = Contestant.new(contestant_params)
    if contestant.save
      render json: contestant, status: :created
    else
      render json: { errors: contestant.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    contestant = Contestant.find(params[:id])
    if contestant.update(contestant_params)
      render json: contestant
    else
      render json: { errors: contestant.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    contestant = Contestant.find(params[:id])
    contestant.destroy
    head :no_content
  end

  private

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def contestant_params
    params.require(:contestant).permit(:name, :gender, :tribename, :season_id, :occupation, :bio, :age, :photo_url, :video_url)
  end
end
