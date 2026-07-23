class AddBlueskyUrlToMemes < ActiveRecord::Migration[8.1]
  def change
    add_column :memes, :bluesky_url, :string
  end
end
