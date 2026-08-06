class PollVotesController < ApplicationController
  before_action :authenticate_user!

  def create
    vote = current_user.poll_votes.new(poll_vote_params)
    if vote.save
      render json: vote.poll.result_json(current_user), status: :created
    else
      render json: { errors: vote.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def poll_vote_params
    params.require(:poll_vote).permit(:poll_id, :poll_option_id, :comment)
  end
end
