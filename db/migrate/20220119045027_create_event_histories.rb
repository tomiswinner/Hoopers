class CreateEventHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :event_histories do |t|
      t.references :event,   null: false, foreign_key: true
      t.references :user,    null: false, foreign_key: true

      t.index [:event_id, :user_id], unique: true
      
      t.timestamps
    end
  end
end
