class PollsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :destroy ]
  before_action :require_admin!, only: [ :create, :destroy ]
  before_action :set_poll, only: [ :destroy ]

  def index
    episode_post_id = params.require(:episode_post_id)
    polls = Poll.where(episode_post_id: episode_post_id)
                .includes(:episode_post, poll_options: :poll_votes, poll_votes: :user, poll_comments: :user)

    render json: polls.map { |poll| poll.result_json(current_user) }
  end

  def create
    poll = Poll.new(poll_params)
    if poll.save
      render json: poll.result_json(current_user), status: :created
    else
      render json: { errors: poll.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    @poll.destroy
    head :no_content
  end

  private

  def set_poll
    @poll = Poll.find(params[:id])
  end

  def require_admin!
    unless current_user&.admin?
      render json: { error: "You are not authorized to perform this action." }, status: :forbidden
    end
  end

  def poll_params
    params.require(:poll).permit(:episode_post_id, :question, poll_options_attributes: [ :text ])
  end
end
