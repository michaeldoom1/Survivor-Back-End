class CreateEpisodeScores < ActiveRecord::Migration[8.1]
  def change
    create_table :episode_scores do |t|
      t.references :contestant, null: false, foreign_key: true
      t.references :scoring_event, null: false, foreign_key: true
      t.integer :episode_number, null: false
      t.integer :season_number, null: false
      t.integer :points, null: false

      t.timestamps
    end

    add_index :episode_scores, [ :contestant_id, :episode_number, :scoring_event_id ],
              unique: true, name: "index_episode_scores_on_contestant_episode_event"
  end
end
