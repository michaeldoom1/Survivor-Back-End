class Poll < ApplicationRecord
  belongs_to :episode_post
  has_many :poll_options, -> { order(:id) }, dependent: :destroy, inverse_of: :poll
  has_many :poll_votes, dependent: :destroy

  accepts_nested_attributes_for :poll_options, allow_destroy: true

  validates :question, presence: true
  validate :has_at_least_two_options

  def result_json(for_user)
    my_vote = for_user && poll_votes.find { |vote| vote.user_id == for_user.id }
    voted = my_vote.present?

    {
      id: id,
      episode_post_id: episode_post_id,
      question: question,
      voted: voted,
      my_option_id: my_vote&.poll_option_id,
      options: poll_options.map { |option|
        { id: option.id, text: option.text, vote_count: voted ? option.poll_votes.size : nil }
      },
      total_votes: voted ? poll_votes.size : nil,
      comments: voted ? comments_json : []
    }
  end

  private

  def comments_json
    poll_votes.select { |vote| vote.comment.present? }.map { |vote|
      {
        id: vote.id,
        comment: vote.comment,
        user_name: "#{vote.user.first_name} #{vote.user.last_name}",
        created_at: vote.created_at
      }
    }
  end

  def has_at_least_two_options
    if poll_options.reject(&:marked_for_destruction?).size < 2
      errors.add(:base, "must have at least two options")
    end
  end
end
