class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items, id: :uuid do |t|
      t.string     :name, null: false
      t.text       :description
      t.integer    :category, default: 0, null: false
      t.integer    :condition, default: 0, null: false
      t.boolean    :available, default: true, null: false
      t.boolean    :flagged, default: false, null: false
      t.references :user, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :items, :category
    add_index :items, :available
    add_index :items, :flagged
    add_index :items, %i[available flagged]
  end
end
