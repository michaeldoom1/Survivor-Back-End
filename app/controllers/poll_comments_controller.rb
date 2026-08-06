class PollCommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    poll = Poll.find(poll_comment_params[:poll_id])
    unless poll.eligible?(current_user)
      render json: { errors: [ "You must submit picks for this season before commenting." ] }, status: :forbidden
      return
    end

    comment = current_user.poll_comments.new(poll_comment_params)
    if comment.save
      render json: comment.poll.result_json(current_user), status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def poll_comment_params
    params.require(:poll_comment).permit(:poll_id, :body)
  end
end
