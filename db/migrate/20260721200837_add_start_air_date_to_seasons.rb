class AddStartAirDateToSeasons < ActiveRecord::Migration[8.1]
  def change
    add_column :seasons, :start_air_date, :datetime
  end
end
