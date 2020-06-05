class AddInvitationToGameSession < ActiveRecord::Migration[5.2]
  def change
    add_column :game_sessions, :invitation_accepted, :boolean, default: false
    add_index :game_sessions, :invitation_accepted
  end
end
