class PollComment < ApplicationRecord
  belongs_to :poll
  belongs_to :user

  validates :body, presence: true
  validates :user_id, uniqueness: { scope: :poll_id, message: "has already commented on this poll" }
end
