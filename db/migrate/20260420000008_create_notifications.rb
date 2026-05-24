class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user,  type: :uuid, null: false, foreign_key: true
      t.references :actor,  type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :notifiable, type: :uuid, polymorphic: true, null: false
      t.string     :action, null: false
      t.datetime   :read_at

      t.timestamps
    end

    add_index :notifications, %i[user_id read_at]
  end
end
