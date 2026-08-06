class CreatePolls < ActiveRecord::Migration[8.1]
  def change
    create_table :polls do |t|
      t.references :episode_post, null: false, foreign_key: true
      t.text :question, null: false

      t.timestamps
    end
  end
end
