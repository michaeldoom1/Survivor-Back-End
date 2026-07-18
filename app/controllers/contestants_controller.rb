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
            event_points: episode_score.scoring_event.points,
            count: episode_score.count,
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
    person, person_errors = find_or_create_person(params.dig(:contestant, :name), params.dig(:contestant, :gender))
    if person.nil?
      render json: { errors: person_errors }, status: :unprocessable_content
      return
    end

    contestant = Contestant.new(contestant_params.merge(person: person))
    if contestant.save
      render json: contestant, status: :created
    else
      render json: { errors: contestant.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    contestant = Contestant.find(params[:id])
    person, person_errors = find_or_create_person(params.dig(:contestant, :name), params.dig(:contestant, :gender))
    if person.nil?
      render json: { errors: person_errors }, status: :unprocessable_content
      return
    end

    if contestant.update(contestant_params.merge(person: person))
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
    params.require(:contestant).permit(:tribename, :season_id, :occupation, :bio, :age, :photo_url, :video_url)
  end

  # Name is how we identify a real person across seasons: an exact match
  # reuses their existing Person (and every other season they're linked to),
  # otherwise a new Person is created. Cross-season name collisions that are
  # NOT the same real person have to be resolved by hand (see db/seeds.rb
  # for the precedent set when importing historical seasons).
  #
  # Returns [person, nil] on success or [nil, error_messages] on failure,
  # rather than raising, so invalid input reaches the client as a normal
  # 422 with error messages instead of a generic 400/500.
  def find_or_create_person(name, gender)
    existing = Person.find_by(name: name) if name.present?
    return [ existing, nil ] if existing

    person = Person.new(name: name, gender: gender)
    person.save ? [ person, nil ] : [ nil, person.errors.full_messages ]
  end
end
