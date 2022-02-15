require 'active_support/concern'

module TurnBehaviour
	extend ActiveSupport::Concern

	def next_turn
		logging("Game Step 3", "Next turn, #{self.set}")
		# reset turn passing number and completed
		current_turn[:passed] = 0 if current_turn[:passed].present?
		current_turn[:completed] = false
		if team_mode
			# find current team
			team_number = current_turn[:team]
			logging("Game Step 3.1", "Last Team Order, #{team_number}")

			# put last player into 'gone' list according to team
			players_gone[team_number.to_s] << current_turn[:nominated_player] if current_turn[:nominated_player].present?

			# check if we are at the end of the teams
			if team_number == teams.length
				current_turn[:team] = 1
			else
				current_turn[:team] += 1
			end
		else
			# put last player into 'gone' list without team
			players_gone << current_turn[:nominated_player] if current_turn[:nominated_player].present?
		end
		next_player
	end

	def next_player
		logging("Game Step 4", "Next player #{self.set}")

		if team_mode
			new_team_number = current_turn[:team]
			logging("Game Step 4.1", "Team order #{new_team_number}")

			new_team = teams.where(order: new_team_number).take

			logging("Game Step 4.2", "Found current team #{new_team}, #{self.set}")
			
			players = new_team.game_sessions.sort_by(&:id).map(&:id)

			logging("Game Step 4.3", "Current team members #{players} \n Current team number #{new_team_number} \n Current team gone players #{players_gone[new_team_number.to_s]}")

			if players_gone[new_team_number.to_s].present?
				players_left = players - players_gone[new_team_number.to_s]
			else
				players_left = players
			end

		else
			players = game_sessions.sort_by(&:id).map(&:id)

			logging("Game Step 4.1", "current team members #{players}")

			if players_gone.present?
				players_left = players - players_gone
			else
				players_left = players
			end
		end
		
		if players_left.empty? && team_mode
			players_left = players
			players_gone[new_team_number.to_s] = []
		elsif players_left.empty? && !team_mode
			players_left = players
			self.players_gone = []
		end

		current_turn[:nominated_player] = players_left.sample

		logging("Game Step 4.5", "Found next player #{players_left.first}, #{self.set}")
	end
end