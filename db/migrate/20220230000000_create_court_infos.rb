class CreateCourtInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :court_infos do |t|
      t.references :court,          null: false, foreign_key: true
      t.references :user,           null: false, foreign_key: true
      t.string :information,        null: false
      t.boolean :status,            null: false, default: false

      t.index [:court_id, :user_id], unique: true

      t.timestamps
    end
  end
end
