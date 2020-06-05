class FishBowl < Game
	before_create :game_setup
	before_update :start_game, if: :started_changed?
	before_update :populate_pot, if: :only_clue_keys?
	before_update :play, if: :start_round_one?

	ROUNDS = { 
					0 => { name: "Clues", instructions: "Please fill in up to 5 clues each person", score_round: false}, 
					1 => { name: "Taboo", instructions: "Each player will have 60 seconds to provide verbal hints for their team to guess each clue. The verbal hints can not be any part of the clue. Team members can guess by typing in the answer, when matched, next clue will be drawn.", score_round: true}, 
					2 => { name: "Charades", instructions: "Each player will have 60 seconds to act out the clues for their team to guess. Team members can guess by typing in the answer, when matched, next clue will be drawn", score_round: true}, 
					3 => { name: "Password", instructions: "Each player will have 60 seconds to provide 1 keyword for their team to guess. Team members can guess by typing in the answer, when matched, next clue will be drawn", score_round: true}
				}
	def start_game
		if started == true
			logger.debug("#{self}: starting game, #{self.set}")
			set["current_round"]["round_number"] = 0
			teams.each_with_index do |team, index|
				team.update_attributes(order: (index + 1))
			end
		end
	end

	def play
		logger.debug("#{self}: playing game, #{self.set}")
		if set["current_round"]["completed"] == true || set["clues"].empty?
			next_round
		else
			# next team
			next_turn
		end
	end

	def next_round
		logger.debug("#{self}: next round, #{self.set}")
		if set["current_round"]["round_number"] == rounds.keys.last
			set["current_round"]["completed"] = true
			self.ended = true
		else
			set["current_round"]["round_number"] += 1
			set["current_round"]["completed"] = false
			next_turn
		end
	end

	def next_turn
		logger.debug("#{self}: next turn, #{self.set}")
		if set["current_turn"]["team"] == teams.length
			set["current_turn"]["team"] = 1
		else
			set["current_turn"]["team"] += 1
		end
		next_player
	end


	def next_player
		current_team = teams.where(order: set["current_turn"]["team"]).take
		logger.debug("#{self}: team order #{set["current_turn"]["team"]}")
		logger.debug("#{self}: current team #{current_team.id}, #{self.set}")
		
		players = current_team.game_sessions.map(&:id)

		logger.debug("#{self}: current team members #{players}")
		if set["current_turn"]["nominated_player"].present?
			set["current_turn"]["gone_players"] << set["current_turn"]["nominated_player"]
		end
		logger.debug("#{self}: players gone, #{self.set}")
		left_players = players - set["current_turn"]["gone_players"]
		logger.debug("#{self}: left players, #{left_players}")
		if left_players.empty?
			left_players = players
			set["current_turn"]["gone_players"] = []
		end
		logger.debug("#{self}: next player #{left_players.first}, #{self.set}")
		self.set["current_turn"]["nominated_player"] = left_players.first
	end

	def clue_round?
		return self.set["current_round"]["round_number"] == 0
	end

	def start_round_one?
		!started_changed? && set_changed?
	end

	def populate_pot
		old_set = self.set_was
		logger.debug("Current Game set #{self.set}")
		logger.debug("Current Game set keys #{self.set.keys}")
		self.set.keys.each do|key|
			if ["clues", "players_gone"].include?(key)
				old_set[key] += set[key]
				old_set[key] = old_set[key].uniq.reject { |x| x == ""}
			end
		end
		self.set = old_set
	end

	def only_clue_keys?
		if set_changed?
			keys_included = (self.set.keys - ["clues", "players_gone"]).empty?
			logger.debug("Current Game set keys #{self.set.keys} only have 'clues', 'players_gone', #{keys_included}")
			return keys_included
		else
			return false
		end
	end

	private
		def game_setup
			self.set = { clues: [], 
				guessed_clues: [],
				current_round: { 
					round_number: nil,
					completed: false
				},
				current_turn: { team: 0, nominated_player: nil, gone_players: [], time_left: nil },
				# only user ids in array
				players_gone: []
			}
		end
end