class AddSeasonToContestant < ActiveRecord::Migration[8.1]
  def change
    add_column :contestants, :season, :integer, null: false
  end
end
