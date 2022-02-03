class CreateCourtFavorites < ActiveRecord::Migration[5.2]
  def change
    create_table :court_favorites do |t|
      t.references :court,    null: false, foreign_key: true
      t.references :user,     null: false, foreign_key: true


      t.timestamps
    end
  end
end
