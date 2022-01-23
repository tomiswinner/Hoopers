class CreateCourts < ActiveRecord::Migration[5.2]
  def change
    create_table :courts do |t|
      t.references :user,                           null: false, foreign_key: true
      t.references :area,                           null: false, foreign_key: true
      t.string :name,                               null: false
      t.string :image_id,                           null: false
      t.string :address,                            null: false
      t.decimal :latitude, precision: 9, scale: 6,  null: false
      t.decimal :longitude, precision: 9, scale: 6, null: false
      t.time :open_time
      t.time :close_time
      t.string :url,                                null: false,                    defalut: 'なし'
      t.string :supplement,                         null: false,                    defalut: 'なし'
      t.string :size,                               null: false,                    defalut: '確認中'
      t.string :price,                              null: false,                    defalut: '確認中'
      t.integer :type,                              null: false,                    defalut: 5
      t.boolean :bussiness_status,                  null: false,                    defalut: true
      t.boolean :confirmation_status,               null: false,                    defalut: false

      t.timestamps
    end
  end
end
