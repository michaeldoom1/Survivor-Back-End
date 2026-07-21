class PicksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pick, only: [ :show, :update, :destroy ]

  # The golden goose pick counts for double whatever that contestant actually scored.
  GOLDEN_GOOSE_MULTIPLIER = 2

  def index
    render json: current_user.picks
  end

  def by_season
    season_id = params.require(:season_id)
    picks = Pick.where(season_id: season_id)
                .includes(
                  :user, :season,
                  male_contestant: :episode_scores,
                  female_contestant: :episode_scores,
                  golden_goose_contestant: :episode_scores
                )

    render json: picks.map { |pick|
      male_points = pick.male_contestant.total_points
      female_points = pick.female_contestant.total_points
      golden_goose_points = pick.golden_goose_contestant.total_points * GOLDEN_GOOSE_MULTIPLIER

      {
        user_id: pick.user_id,
        user_name: "#{pick.user.first_name} #{pick.user.last_name}",
        season_id: pick.season_id,
        season_number: pick.season.number,
        male_contestant: { id: pick.male_contestant.id, name: pick.male_contestant.name, points: male_points },
        female_contestant: { id: pick.female_contestant.id, name: pick.female_contestant.name, points: female_points },
        golden_goose_contestant: {
          id: pick.golden_goose_contestant.id,
          name: pick.golden_goose_contestant.name,
          points: golden_goose_points
        },
        total_points: male_points + female_points + golden_goose_points
      }
    }
  end

  def show
    render json: @pick
  end

  def create
    pick = current_user.picks.new(pick_params)
    if pick.save
      render json: pick, status: :created
    else
      render json: { errors: pick.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @pick.update(pick_params)
      render json: @pick
    else
      render json: { errors: @pick.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @pick.destroy
    head :no_content
  end

  private

  def set_pick
    @pick = current_user.picks.find(params[:id])
  end

  def pick_params
    params.require(:pick).permit(:season_id, :male_contestant_id, :female_contestant_id, :golden_goose_contestant_id)
  end
end
