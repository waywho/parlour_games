class AddGameSessionToTeam < ActiveRecord::Migration[5.2]
  def change
    add_reference :teams, :game_session, foreign_key: true
  end
end
