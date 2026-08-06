class PollVote < ApplicationRecord
  belongs_to :poll
  belongs_to :poll_option
  belongs_to :user

  validates :user_id, uniqueness: { scope: :poll_id, message: "has already voted on this poll" }
  validate :poll_option_belongs_to_poll

  private

  def poll_option_belongs_to_poll
    return if poll_option.nil? || poll.nil?

    unless poll_option.poll_id == poll_id
      errors.add(:poll_option, "must belong to the selected poll")
    end
  end
end
