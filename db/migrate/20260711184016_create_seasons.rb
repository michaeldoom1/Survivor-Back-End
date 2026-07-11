class CreateSeasons < ActiveRecord::Migration[8.1]
  def change
    create_table :seasons do |t|
      t.integer :number, null: false

      t.timestamps
    end

    add_index :seasons, :number, unique: true
  end
end
