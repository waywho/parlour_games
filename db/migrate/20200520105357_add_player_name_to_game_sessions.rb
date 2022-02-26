class AddPlayerNameToGameSessions < ActiveRecord::Migration[5.2]
  def change
    add_column :game_sessions, :player_name, :string
    add_column :game_sessions, :ip_address, :string

    reversible do |dir|
  		dir.up { 
  			GameSession.all.each do |g|
  				g.update(player_name: g.playerable.name, ip_address: g.playerable.try(:ip_address))
  			end
  		}
  	
  	end
  end
end
