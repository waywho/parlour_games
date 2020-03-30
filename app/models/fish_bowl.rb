class FishBowl < Game
	before_create :game_setup

	def play(guessed_clues, starting_clues=nil)
		if starting_clues.present?
			self.set["clues"] = staring_clues
			set["current_round"]["round_number"] = 1
			set["turn"]["current_team"] = 1
		else
			remaining_clues = set.staring_clues - guessed_clues
			next_team
			if remaining_clues.empty?
				next_round
			end
		end
		return { "team": self.teams.find(self.set["current_team"]), "round": self.set["rounds"][self.set["current_round"]["round_number"]] }
	end

	def next_team
		if set["turn"]["current_team"] == set.teams.length
			set["turn"]["current_team"] = 1
		else
			set["turn"]["current_team"] += 1
		end
	end

	def next_round
		if set["current_round"]["round_number"] == set.rounds.length
			# game finished
		else
			set["current_round"]["round_number"] += 1 
		end
	end

	def nominate(player_id)
		self.set["turn"]["nominated_player"] = player_id
	end


	private
		def game_setup
			self.set = { clues: [], 
				guessed_clues: [], 
				rounds: { "1" => "Taboo", "2" => "Charades", "3" => "Password"},
				current_round: { round_number: nil, teams: {} },
				turn: { current_team: nil, nominated_player: nil }
			}
		end
end