class AddProfileFieldsToContestants < ActiveRecord::Migration[8.1]
  def change
    add_column :contestants, :occupation, :string
    add_column :contestants, :bio, :text
    add_column :contestants, :age, :integer
    add_column :contestants, :photo_url, :string
    add_column :contestants, :video_url, :string
  end
end
