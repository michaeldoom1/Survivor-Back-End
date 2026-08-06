class Poll < ApplicationRecord
  belongs_to :episode_post
  has_many :poll_options, -> { order(:id) }, dependent: :destroy, inverse_of: :poll
  has_many :poll_votes, dependent: :destroy
  has_many :poll_comments, dependent: :destroy

  accepts_nested_attributes_for :poll_options, allow_destroy: true

  validates :question, presence: true
  validate :has_at_least_two_options

  def eligible?(user)
    user && Pick.exists?(user_id: user.id, season_id: episode_post.season_id)
  end

  def result_json(for_user)
    my_vote = for_user && poll_votes.find { |vote| vote.user_id == for_user.id }
    my_comment = for_user && poll_comments.find { |comment| comment.user_id == for_user.id }
    voted = my_vote.present?

    {
      id: id,
      episode_post_id: episode_post_id,
      question: question,
      can_participate: eligible?(for_user),
      voted: voted,
      my_option_id: my_vote&.poll_option_id,
      options: poll_options.map { |option|
        { id: option.id, text: option.text, vote_count: voted ? option.poll_votes.size : nil }
      },
      total_votes: voted ? poll_votes.size : nil,
      my_comment_id: my_comment&.id,
      comments: comments_json
    }
  end

  private

  def comments_json
    poll_comments.map { |comment|
      {
        id: comment.id,
        comment: comment.body,
        user_name: "#{comment.user.first_name} #{comment.user.last_name}",
        created_at: comment.created_at
      }
    }
  end

  def has_at_least_two_options
    if poll_options.reject(&:marked_for_destruction?).size < 2
      errors.add(:base, "must have at least two options")
    end
  end
end
