class ChangeUserToGameSessions < ActiveRecord::Migration[5.2]
  def change
  	add_reference :game_sessions, :playerable, polymorphic: true
  	reversible do |dir|
  		dir.up { GameSession.update_all("playerable_id=user_id, playerable_type='User'")}
  		dir.down { GameSession.update_all("user_id=playerable_id")}
  	end
  	remove_reference :game_sessions, :user, index: true, foreign_key: true
  end
end
