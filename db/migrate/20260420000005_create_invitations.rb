class CreateInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :inviter, type: :uuid, null: false, foreign_key: { to_table: :users }
      t.references :neighborhood, type: :uuid, null: false, foreign_key: true
      t.string     :invitee_email, null: false
      t.string     :token, null: false
      t.integer    :status, default: 0, null: false # 0=pending, 1=accepted, 2=expired

      t.timestamps
    end

    add_index :invitations, :token, unique: true
    add_index :invitations, :invitee_email
  end
end
