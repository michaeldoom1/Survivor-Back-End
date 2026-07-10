class CreateContestants < ActiveRecord::Migration[8.1]
  def change
    create_table :contestants do |t|
      t.string :name, null: false
      t.string :gender, null: false
      t.string :tribename

      t.timestamps
    end
  end
end
