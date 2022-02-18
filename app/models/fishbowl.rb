class Fishbowl < Game
	include TurnBehaviour

	# store :turn_order, accessors: [:current_turn, :players_gone], coder: JSON
	store :set, accessors: [:clues, :current_round, :players_done_clues, :rounds_played], coder: JSON
	store :options, accessors: [:time_limit, :enable_team_mode, :enable_chat], coder: JSON
	store :interactions, accesssors: [:current_clue, :guessed_clues], coder: JSON
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
			current_round[:round_number] = 0
		end
	end

	# Play logic runs every update after game start with before_update
	# For fishbowl game, play governs turn exchange if the game is not completed
	def play
		logging("Game Step 1", "playing game, #{self.set}")
		if current_round[:completed] == true || set["clues"].empty?
			current_round[:completed] = true
			next_round
		elsif current_turn[:completed] == true
			# next team
			next_turn
		end
	end

	# Fishbowl game rounds are set, when one round is completed then next round is set
	def next_round
		logging("Game Step 2", "Next round, #{self.set}")
		round_info = self.rounds[current_round[:round_number]]
		rounds_played[current_round[:round_number]] = { name: round_info[:name], score_round: round_info[:score_round]}
		if current_round[:round_number] == rounds.keys.last
			current_round[:completed] = true
			current_turn[:team] = 0
			current_turn["nominated_player"] = nil
			self.ended = true
		elsif !current_round[:round_number].nil?
			if current_round[:round_number] > 0
				set["clues"] = interactions["guessed_clues"].uniq
				logging("Game Step 2", "Reset clues, #{self.set["clues"]}")
				interactions["guessed_clues"] = []
			end
			current_round[:round_number] += 1
			current_round[:completed] = false
	
			next_turn
		end
	end

	# check stage of the game, if it is after the clue setup round
	def after_clues?
		if current_round[:round_number].nil?
			return false
		elsif current_round[:round_number] == 0 && current_round[:completed] == true
			return true
		elsif current_round[:round_number] > 0
			return true
		else
			return false
		end
	end

	# when users add clues to the game pot, process the clues for unique clues and remove empty items
	def populate_pot
		old_set = self.set_was
		logging("Game Setup", "Previous Game set #{self.set_was}")
		logging("Game Setup", "Current Game set keys #{self.set.keys}")
		
		self.set.keys.each do|key|
			if ["clues", "players_done_clues"].include?(key)
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
			keys_included = (self.set.keys - ["clues", "players_done_clues"]).empty?
			logger.tagged("#{self}") { logger.tagged("Game Setup Check")  { logger.debug("Checking current Game set keys #{self.set.keys} ONLY include 'clues', 'players_done_clues': #{keys_included}") } }
			return keys_included
		else
			return false
		end
	end

	private
		def game_setup
			self.turn_order = {
 				current_turn: { 
					team: 0, 
					nominated_player: nil, 
					passed: 0, 
					time_left: 0, 
					completed: false 
				},
				# only user ids in array
				players_gone: nil				
 			}
			self.interactions = {
				current_clue: nil,
				guessed_clues: [],
			}
			self.set = { 
				clues: [], 				
				current_round: { 
					round_number: nil,
					completed: false
				},
				players_done_clues: [],
				rounds_played: {}
			}
			self.options = {
				time_limit: 60,
				enable_team_mode: true,
				enable_chat: false
			}
		end
end
