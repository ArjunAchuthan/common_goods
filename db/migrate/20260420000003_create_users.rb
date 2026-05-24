class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string   :email,           null: false
      t.string   :password_digest, null: false
      t.string   :name,            null: false
      t.string   :address
      t.st_point :location, geographic: true, srid: 4326
      t.integer  :role, default: 0, null: false # 0=member, 1=captain, 2=admin
      t.references :neighborhood, type: :uuid, foreign_key: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :location, using: :gist
    add_index :users, :role
  end
end
