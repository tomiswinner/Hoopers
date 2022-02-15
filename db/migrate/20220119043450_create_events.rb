class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.references :court,    null: false, foreign_key: true
      t.references :user,     null: false, foreign_key: true
      t.string :name,         null: false
      t.string :image_id
      t.string :description,  null: false
      t.string :condition,    null: false
      t.string :contact,      null: false
      t.datetime :open_time,  null: false
      t.datetime :close_time, null: false
      t.integer :status,      null: false,                   default: true

      t.timestamps
    end
  end
end
