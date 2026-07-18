class FinalizePersonOnContestants < ActiveRecord::Migration[8.1]
  def change
    change_column_null :contestants, :person_id, false
    remove_column :contestants, :name, :string
    remove_column :contestants, :gender, :string
  end
end
