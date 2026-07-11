class CreateScoringEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :scoring_events do |t|
      t.string :name, null: false
      t.integer :points, null: false

      t.timestamps
    end

    add_index :scoring_events, :name, unique: true
  end
end
