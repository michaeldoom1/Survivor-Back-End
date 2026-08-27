class AddCurrentCityToContestants < ActiveRecord::Migration[8.1]
  def change
    add_column :contestants, :current_city, :string
  end
end
