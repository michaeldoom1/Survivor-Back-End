class RemoveCommentFromPollVotes < ActiveRecord::Migration[8.1]
  def change
    remove_column :poll_votes, :comment, :text
  end
end
