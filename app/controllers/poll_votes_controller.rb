class PollVotesController < ApplicationController
  before_action :authenticate_user!

  def create
    poll = Poll.find(poll_vote_params[:poll_id])
    unless poll.eligible?(current_user)
      render json: { errors: [ "You must submit picks for this season before voting." ] }, status: :forbidden
      return
    end

    vote = current_user.poll_votes.new(poll_vote_params)
    if vote.save
      render json: vote.poll.result_json(current_user), status: :created
    else
      render json: { errors: vote.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def poll_vote_params
    params.require(:poll_vote).permit(:poll_id, :poll_option_id)
  end
end
