class Fishbowl < Game
	before_create :game_setup
	before_update :start_game, if: :started_changed?
	before_update :populate_pot, if: :only_clue_keys?
	before_update :play, if: :after_clues?

	ROUNDS = { 
					0 => { name: "Clues", instructions: "Please add clues into the fishbowl. These clues will be used to be guessed by your fellow players through rounds of Taboo, Charades, and Password.", score_round: false}, 
					1 => { name: "Taboo", instructions: "Each player will have 60 seconds to provide verbal hints for their team to guess each clue. The verbal hints can not be any part of the clue. Team members can guess by typing in the answer, when matched, next clue will be drawn.", score_round: true}, 
					2 => { name: "Charades", instructions: "Each player will have 60 seconds to act out the clues for their team to guess. Team members can guess by typing in the answer, when matched, next clue will be drawn", score_round: true}, 
					3 => { name: "Password", instructions: "Each player will have 60 seconds to provide 1 keyword for their team to guess. Team members can guess by typing in the answer, when matched, next clue will be drawn", score_round: true}
				}

	DESCRIPTION = "This is a great group game. Teams will guess the same clues through rounds of giving descriptions (Taboo), acting out (Charades), and single describing word (Password). "
	
	def start_game
		if started
			logging("Game Step 0", "starting game, #{self.set}")
			set["current_round"]["round_number"] = 0
			if teams.present?
				teams.each_with_index do |team, index|
					team.update_attributes(order: (index + 1))
					set["gone_players"][index + 1] = []
				end
			end
		end
	end

	def play
		logging("Game Step 1", "playing game, #{self.set}")
		if set["current_round"]["completed"] == true || set["clues"].empty?
			set["current_round"]["completed"] = true
			next_round
		elsif set["current_turn"]["completed"] == true
			# next team
			next_turn
		end
	end

	def next_round
		logging("Game Step 2", "Next round, #{self.set}")
		if set["current_round"]["round_number"] == rounds.keys.last
			set["current_round"]["completed"] = true
			set["current_turn"]["team"] = 0
			set["current_turn"]["nominated_player"] = nil
			self.ended = true
		elsif !set["current_round"]["round_number"].nil?
			if set["current_round"]["round_number"] > 0
				set["clues"] = set["guessed_clues"].uniq
				logging("Game Step 2", "Reset clues, #{self.set["clues"]}")
				set["guessed_clues"] = []
			end
			set["current_round"]["round_number"] += 1
			set["current_round"]["completed"] = false
	
			next_turn
		end
	end

	

	def after_clues?
		if set["current_round"]["round_number"].nil?
			return false
		elsif set["current_round"]["round_number"] == 0 && set["current_round"]["completed"] == true
			return true
		elsif set["current_round"]["round_number"] > 0
			return true
		else
			return false
		end
	end

	def populate_pot
		old_set = self.set_was
		logging("Game Setup", "Previous Game set #{self.set_was}")
		logging("Game Setup", "Current Game set keys #{self.set.keys}")
		
		self.set.keys.each do|key|
			if ["clues", "players_gone"].include?(key)
				old_set[key] += set[key]
				if key == "clues"
					old_set[key] = old_set[key].uniq(&:downcase).reject { |x| x == ""}
				else
					old_set[key] = old_set[key].uniq.reject { |x| x == ""}
				end
			end
		end
		self.set = old_set
	end

	def only_clue_keys?
		if set_changed?
			keys_included = (self.set.keys - ["clues", "players_gone"]).empty?
			logger.tagged("#{self}") { logger.tagged("Game Setup Check")  { logger.debug("Checking current Game set keys #{self.set.keys} ONLY include 'clues', 'players_gone': #{keys_included}") } }
			return keys_included
		else
			return false
		end
	end

	private
		def game_setup
			self.set = { clues: [], 
				current_clue: nil,
				guessed_clues: [],
				current_round: { 
					round_number: nil,
					completed: false
				},
				current_turn: { team: 0, nominated_player: nil, passed: 0, time_left: 0, completed: false },
				# only user ids in array
				gone_players: [],
				players_gone: [],
				options: {
					time_limit: 60,
					team_mode: true
				}
			}
		end
end