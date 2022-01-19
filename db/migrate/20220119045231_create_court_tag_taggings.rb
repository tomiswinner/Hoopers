class CreateCourtTagTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :court_tag_taggings do |t|
      t.references :court,    null: false, foreign_key: true
      t.references :tag,      null: false, foreign_key: true

      t.timestamps
    end
  end
end
