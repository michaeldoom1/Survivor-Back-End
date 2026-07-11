class ReplaceSeasonNumberWithSeasonIdOnPicks < ActiveRecord::Migration[8.1]
  def change
    remove_column :picks, :season_number, :integer
    add_reference :picks, :season, null: false, foreign_key: true

    add_index :picks, [ :user_id, :season_id ], unique: true
  end
end
