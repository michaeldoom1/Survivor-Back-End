class AddPersonToContestants < ActiveRecord::Migration[8.1]
  def change
    # Nullable for now so existing rows can be backfilled; a follow-up
    # migration tightens this to null: false once every row has a person.
    add_reference :contestants, :person, null: true, foreign_key: true
  end
end
