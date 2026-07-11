class CreatePicks < ActiveRecord::Migration[8.1]
  def change
    create_table :picks do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :season_number, null: false
      t.integer :male_contestant_id, null: false
      t.integer :female_contestant_id, null: false
      t.integer :golden_goose_contestant_id, null: false

      t.timestamps
    end

    add_foreign_key :picks, :contestants, column: :male_contestant_id
    add_foreign_key :picks, :contestants, column: :female_contestant_id
    add_foreign_key :picks, :contestants, column: :golden_goose_contestant_id
    add_index :picks, :male_contestant_id
    add_index :picks, :female_contestant_id
    add_index :picks, :golden_goose_contestant_id
    add_index :picks, [ :user_id, :season_number ], unique: true
  end
end
