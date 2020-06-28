class WinkMurder < Game
	before_create :game_setup
	store_accessor :set, :rounds_played, :current_round, :options
	before_update :start_game, if: :started_changed?
	before_update :play, if: :after_started?

	ROUNDS = {
		1  => { name: "1", score_round: true }
	}
	DESCRIPTION = ""

	def start_game
		if started
			current_round["round_number"] += 1
			setup_round
		end
	end

	def play
		if current_round["completed"] && !ended
			next_round
		else
			current_round["killed"][current_turn["murderer"].to_s] << current_turn["killed"]

			winning_murderer = game_sessions.find_by_id(current_turn["murderer"])
			winning_murderer.scores[current_round["round_number"].to_s] += 1 

			number_of_murderers = current_round["murderers"].length
			civilian_numbers = game_sessions.length - number_of_murderers
			all_killed = current_round["killed"].values.flatten
			if all_killed.length == civilian_numbers
				current_round["completed"] = true
			end
		end
	end

	def next_round
		rounds_played[current_round["round_number"]] = current_round
		current_round["killed"] = {}
		current_round["round_number"] += 1
		game_sessions.each do  |session|
			session.scores[current_round["round_number"].to_s] = 0
			session.save		
		end
		setup_round
	end

	def setup_round
		players = game_sessions
		murderers = []
		options["number_of_murderers"].to_i.times do |number|
			randomIndex = rand(game_sessions.length)
			murderers << players.slice(randomIndex).id
		end
		current_round["murderers"] = murderers
		murderers.each do |murderer|
			current_round["killed"][murderer] = []
		end
	end

	def after_started?
		return current_round["round_number"] > 0 && current_turn["killed"].present?
	end

	private

	def game_setup
		self.turn_order = {
			current_turn: { killed: nil, murderer: nil },
			players_gone: []
		}
		self.set = {
			current_round: {
				round_number: 0,
				murderers: [],
				killed: {},
				completed: false
			},
			rounds_played: {},
			options: {
				number_of_murderers: 1,
				enable_chat: false
			}
		}
	end
end