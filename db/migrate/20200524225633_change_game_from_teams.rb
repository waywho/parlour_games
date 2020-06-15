class ChangeGameFromTeams < ActiveRecord::Migration[5.2]
  def up
  	add_reference :teams, :game, type: :uuid, index: true
  	Team.all.each do |team|
  		team.update_attributes(game_id: team.game.first.id)
  	end
  end

  def down
  	add_reference :teams, :game, type: :uuid, index: true
  end
end
