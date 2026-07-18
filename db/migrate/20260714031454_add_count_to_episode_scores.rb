class AddCountToEpisodeScores < ActiveRecord::Migration[8.1]
  def change
    add_column :episode_scores, :count, :integer, default: 1, null: false
  end
end
