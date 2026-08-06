class PollOption < ApplicationRecord
  belongs_to :poll
  has_many :poll_votes, dependent: :destroy

  validates :text, presence: true
end
