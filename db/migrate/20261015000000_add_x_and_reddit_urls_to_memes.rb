class AddXAndRedditUrlsToMemes < ActiveRecord::Migration[8.1]
  def change
    add_column :memes, :x_url, :string
    add_column :memes, :reddit_url, :string
  end
end
