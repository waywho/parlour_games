class WinkMurder < Game
	before_create :game_setup
	store :set, accessors: [:current_round, :rounds_played, :options], coder: JSON
	store :turn_order, accessors: [:current_turn, :looking_turn, :lookers, :players_gone, :accusations], coder: JSON
	store :options, accessors: [:number_of_murderers, :enable_chat], coder: JSON
	before_update :start_game, if: :started_changed?
	before_update :check_accusation_phases
	before_update :play, if: :after_started?

	ROUNDS = {
		1  => { name: "1", score_round: true }
	}

	PHASES = {
		"winking" => {name: "winking", instructions: ""},
		"seconder-seeking" => {name: "seconder seeking", instuction: "Someone has raised a first accusal, looking for a seconder. Would you like to be the seconder?"},
		"accusation" => {name: "accusation", instruction: "You can now accuse someone else as the Wink Murderer. Warning: if you are wrong, you are out of the game."},
		"challenge" => {name: "challenge", instruction: ""}
	}

	DESCRIPTION = ""

	def start_game
		if started
			current_round[:round_number] += 1
			setup_round
		end
	end

	def play
		if current_round[:completed] && !ended
			next_round
		elsif looking_turn[:looker].present? && looking_turn[:looking].present?
			lookers.each do |key, value|
				if value.include?(looking_turn[:looker]) && looking_turn[:looking].to_s == key
					value.delete(looking_turn[:looker])
				end
			end

			lookers[looking_turn[:looking].to_s].push(looking_turn[:looker])
			looking_turn[:looker] = nil
			looking_turn[:looking] = nil

		elsif current_round[:phase] == "challenge"
			possible_full_score = (game_sessions.length / options[:number_of_murderers]).round
			first_accused = accusations[:first][:accused]
			second_accused = accusations[:second][:accused]

			first_accuser = accusations[:first][:accuser]
			second_accuser = accusations[:second][:accuser]

			if first_accused == second_accused && current_round[:murderers].include?(first_accused)
				out_player_id = current_round[:murderers].delete(first_accused)
				player_out(out_player_id, first_accuser)

				player_scores(first_accuser, possible_full_score)
				player_scores(second_accuser, possible_full_score)
			elsif current_round[:murderers].include?(first_accused) && current_round[:murderers].include?(second_accused)
				out_player_id = current_round[:murderers].delete(first_accused)
				player_out(out_player_id, first_accuser)

				out_player_id = current_round[:murderers].delete(second_accused)
				player_out(out_player_id, second_accuser)

				player_scores(first_accuser, possible_full_score)
				player_scores(second_accuser, possible_full_score)

			elsif current_round[:murderers].include?(first_accused) && !current_round[:murderers].include?(accusations[:second][:accused])
				out_player_id = current_round[:murderers].delete(first_accused)
				player_out(out_player_id, first_accuser)

				player_scores(first_accuser, possible_full_score)			
				player_out(second_accuser, "challenge_lost")

			elsif current_round[:murderers].include?(accusations[:second][:accused]) && !current_round[:murderers].include?(first_accused)
				out_player_id = current_round[:murderers].delete(second_accused)
				player_out(out_player_id, second_accuser)

				player_scores(second_accuser, possible_full_score)

				player_out(first_accuser, "challenge_lost")
			else
				player_out(first_accuser, "challenge_lost")
				player_out(second_accuser, "challenge_lost")
			end
			
		elsif current_turn[:outed].present?
			murderer_id = current_turn[:murderer]
			outed_id = current_turn[:outed]

			if lookers[murderer_id.to_s].include?(outed_id) && lookers[outed_id.to_s].include?(murderer_id)
				current_round[:out_list][murderer_id.to_s] << current_turn[:outed]

				player_scores(murderer_id.to_i, 1)
				
				current_turn[:out_list] = nil
				current_turn[:murderer] = nil
				lookers[murderer_id.to_s].delete(outed_id)

				number_of_murderers = current_round[:murderers].length
				civilian_numbers = game_sessions.length - number_of_murderers

				all_out_list = current_round[:out_list].values.flatten
				if all_out_list.length == civilian_numbers
					current_round[:completed] = true
					rounds_played[current_round[:round_number]] = current_round.merge("name" => current_round[:round_number].to_s)
				end
			end
		end
	end

	def player_scores(player_id, score_amount)
		player = game_sessions.find_by_id(player_id)
		player.scores[current_round[:round_number].to_s] += score_amount
		player.save
	end

	def player_out(out_player_id, player_responsible)
		if current_round[:out_list][player_responsible.to_s].nil?
			current_round[:out_list][player_responsible.to_s] = []
		end
		current_round[:out_list][player_responsible.to_s] << out_player_id

	end

	def next_round
		current_round[:out_list] = {}
		# current_round[:round_number] += 1
		current_round[:completed] = false
		game_sessions.each do  |session|
			session.scores[current_round[:round_number].to_s] = 0
			session.save		
		end
		setup_round
	end

	def setup_round
		players = game_sessions
		murderers = []
		options[:number_of_murderers].to_i.times do |number|
			randomIndex = rand(game_sessions.length - 1)
			if !murderers.include?(players[randomIndex].id)
				murderers << players.slice(randomIndex).id
			else
				another_murderer = players[randomIndex + 1] || players[randomIndex - 1]
				murderers << players.slice(players.find_index(another_murderer)).id
			end
		end
		current_round[:murderers] = murderers
		murderers.each do |murderer|
			current_round[:out_list][murderer] = []
		end
		current_round[:out_list][:challenge_lost] = []
		game_sessions.each do |session|
			lookers[session.id] = []
		end
	end

	def check_accusation_phases
		if current_round[:phase] == 'winking'
			accusations.delete_if { |key, value| key == "second" && value.present? }
		elsif current_round[:phase] == "seconder-seeking" 
			accusations[:second] = {}
			accusations[:second][:accuser] = nil
			accusations[:second].delete_if { |key, value| key == "accused" && value.present? }
			accusations[:first].delete_if { |key, value| key == "accused" && value.present? }
		elsif current_round[:phase] == "accusation"
			accusations[:first][:accused] = nil
			accusations[:second][:accused] = nil
		end
	end

	def after_started?
		if current_round[:round_number] > 0 && current_turn[:outed].present?
			return true
		elsif current_round[:round_number] > 0 && looking_turn[:looker].present? && looking_turn[:looking].present?
			return true
		elsif accusations[:first][:accuser].present?
			return true
		elsif current_round[:completed]
			return true
		else
			return false
		end
	end

	private

	def game_setup
		self.turn_order = {
			current_turn: { 
				outed: nil, 
				murderer: nil,
			},
			accusations: { 
				first: {
					accuser: nil
				}
			},
			looking_turn: { looker: nil, looking: nil },
			lookers: {},
			players_gone: []
		}
		self.set = {
			current_round: {
				round_number: 0,
				phase: "winking",
				murderers: [],
				out_list: {},
				score_round: true,
				completed: false
			},
			rounds_played: {}
		}
		self.options = {
			number_of_murderers: 1,
			enable_chat: false
		}
	end
end