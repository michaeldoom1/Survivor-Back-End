class CreateMemes < ActiveRecord::Migration[8.1]
  def change
    create_table :memes do |t|
      t.references :episode_post, null: false, foreign_key: true
      t.string :image_url
      t.string :caption
      t.string :source_url

      t.timestamps
    end
  end
end
