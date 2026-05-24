class CreateLoans < ActiveRecord::Migration[8.0]
  def change
    create_table :loans, id: :uuid do |t|
      t.references :item,     type: :uuid, null: false, foreign_key: true
      t.references :borrower, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.integer    :status,   default: 0, null: false # 0=pending, 1=approved, 2=active, 3=returned, 4=declined
      t.date       :start_date, null: false
      t.date       :end_date,   null: false
      t.text       :message

      t.timestamps
    end

    add_index :loans, :status
    add_index :loans, %i[item_id status]
  end
end
