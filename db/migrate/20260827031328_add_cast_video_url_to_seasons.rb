class AddCastVideoUrlToSeasons < ActiveRecord::Migration[8.1]
  def change
    add_column :seasons, :cast_video_url, :string
  end
end
