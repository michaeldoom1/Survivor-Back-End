class CreateEpisodePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :episode_posts do |t|
      t.references :season, null: false, foreign_key: true
      t.integer :episode_number, null: false
      t.text :recap
      t.text :superlatives

      t.timestamps
    end

    add_index :episode_posts, [ :season_id, :episode_number ], unique: true
  end
end
