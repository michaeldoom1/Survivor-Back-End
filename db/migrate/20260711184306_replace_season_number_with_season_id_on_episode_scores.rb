class ReplaceSeasonNumberWithSeasonIdOnEpisodeScores < ActiveRecord::Migration[8.1]
  def change
    remove_column :episode_scores, :season_number, :integer
    add_reference :episode_scores, :season, null: false, foreign_key: true
  end
end
