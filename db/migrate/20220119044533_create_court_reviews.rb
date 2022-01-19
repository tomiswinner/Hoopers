class CreateCourtReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :court_reviews do |t|
      t.references :court,    null: false, foreign_key: true
      t.references :user,     null: false, foreign_key: true
      t.float :total_points,  null: false
      t.float :accessibility, null: false
      t.float :security,      null: false
      t.float :quality,       null: false

      t.timestamps
    end
  end
end
