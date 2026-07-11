class ScoringEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: [ :create, :update, :destroy ]
  before_action :set_scoring_event, only: [ :show, :update, :destroy ]

  def index
    render json: ScoringEvent.all
  end

  def show
    render json: @scoring_event
  end

  def create
    scoring_event = ScoringEvent.new(scoring_event_params)
    if scoring_event.save
      render json: scoring_event, status: :created
    else
      render json: { errors: scoring_event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def update
    if @scoring_event.update(scoring_event_params)
      render json: @scoring_event
    else
      render json: { errors: @scoring_event.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    if @scoring_event.destroy
      head :no_content
    else
      render json: { errors: @scoring_event.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def set_scoring_event
    @scoring_event = ScoringEvent.find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def scoring_event_params
    params.require(:scoring_event).permit(:name, :points)
  end
end
