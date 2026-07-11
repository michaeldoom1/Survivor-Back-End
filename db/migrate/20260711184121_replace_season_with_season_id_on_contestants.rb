class ReplaceSeasonWithSeasonIdOnContestants < ActiveRecord::Migration[8.1]
  def change
    remove_column :contestants, :season, :integer
    add_reference :contestants, :season, null: false, foreign_key: true
  end
end
