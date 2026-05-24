class CreateNeighborhoods < ActiveRecord::Migration[8.0]
  def change
    create_table :neighborhoods, id: :uuid do |t|
      t.string  :name, null: false
      t.text    :description
      t.st_point :location, geographic: true, srid: 4326
      t.float   :radius_km, default: 2.0
      t.string  :slug, null: false

      t.timestamps
    end

    add_index :neighborhoods, :slug, unique: true
    add_index :neighborhoods, :location, using: :gist
  end
end
