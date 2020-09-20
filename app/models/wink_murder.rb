class WinkMurder < Game

	store :set, accessors: [:current_round, :rounds_played], coder: JSON
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

	# TODO if looking at becomes multiple looking_turn[:lookee] should be array
	# Play logic runs every update after game start with before_update
	# Play logic governs if users are looking at each other, when the Wink murderer winks to kill
	# and when users want to accuse someone as the Wink murderer
	def play
		
		if current_round[:completed] && !ended
			next_round
		elsif looking_turn[:looker].present? && looking_turn[:lookee].present?
			
			# lookers[looking_turn[:lookee].to_s].delete(looking_turn[:looker])
			lookers.each do |key, value|
				if value.include?(looking_turn[:looker])
					value.delete(looking_turn[:looker])
				end
			end

			lookers[looking_turn[:lookee].to_s].push(looking_turn[:looker])
			looking_turn[:lookee] = nil
			looking_turn[:looker] = nil

		elsif current_round[:phase] == "challenge"
			
			number_of_surviving_civilians = game_sessions.length - current_round[:murderers].length - total_out_list.length
			potential_points = ( number_of_surviving_civilians / current_round[:murderers].length).round
			first_accused = accusations[:first][:accused]
			second_accused = accusations[:second][:accused]

			first_accuser = accusations[:first][:accuser]
			second_accuser = accusations[:second][:accuser]

			if current_round[:murderers].include?(first_accused)
				player_out(first_accused, first_accuser)

				player_scores(first_accuser, potential_points)
				accusations[:first] = { accuser: nil }
				end_round?
			else
				player_out(first_accuser, "challenge_lost")
				accusations[:first] = { accuser: nil }
				end_round?
			end

			if current_round[:murderers].include?(second_accused)
				player_out(second_accused, second_accuser)

				player_scores(second_accuser, potential_points)
				accusations.delete(:second)
				end_round?
			else
				player_out(second_accuser, "challenge_lost")
				accusations.delete(:second)
				end_round?
			end
		elsif current_turn[:outed].present?
			murderer_id = current_turn[:murderer]
			outed_id = current_turn[:outed]
			
			if lookers[murderer_id.to_s].include?(outed_id) && lookers[outed_id.to_s].include?(murderer_id)
				
				current_round[:out_list][murderer_id.to_s] << outed_id
				
				player_scores(murderer_id.to_i, 1)

				# lookers[murderer_id.to_s].delete(outed_id)
				current_turn[:outed] = nil
				current_turn[:murderer] = nil

				end_round?
			end
		end
	end

	# Check if all users have gone through their turn
	def all_gone(check_list)
		return check_list.all? {|id| total_out_list.include?(id)}
	end

	def end_round?
		if all_gone(civilian_ids) || all_gone(current_round[:murderers])
			current_round[:completed] = true
			current_round[:phase] = 'winking'
			rounds_played[current_round[:round_number]] = current_round.merge("name" => current_round[:round_number].to_s)
			return
		else
			current_round[:phase] = 'winking'
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
		current_round[:round_number] += 1
		current_turn[:outed] = nil
		current_turn[:murderer] = nil
		current_round[:completed] = false
		game_sessions.each do |session|
			session.scores[current_round[:round_number].to_s] = 0
			session.save
		end
		setup_round
	end

	def setup_round
		player_ids = civilian_ids
		murderers = []
		murderer_numbers = options[:number_of_murderers]
		murderer_numbers.to_i.times do |number|
			remainder_players = player_ids - murderers
			randomIndex = rand(remainder_players.length - 1)
			murderers << remainder_players[randomIndex]
		end
		current_round[:murderers] = murderers
		murderers.each do |murderer|
			current_round[:out_list][murderer] = []
		end
		current_round[:out_list][:challenge_lost] = []
		
		game_sessions.each do |session|
			lookers[session.id] = []
		end

		game_sessions.each do |session|
			list_player_ids = game_sessions.map(&:id)
			list_player_ids.delete(session.id)
			lookers[list_player_ids[rand(list_player_ids.length - 1)]] << session.id
		end
	end

	def total_out_list
		current_round[:out_list].values.flatten
	end

	def civilian_ids
		civilian_ids ||= game_sessions.map(&:id) - current_round[:murderers]
	end

	def check_accusation_phases

		case current_round[:phase]
		when 'winking'
			if accusations[:first][:accuser].present?
				current_round[:phase] = 'seconder-seeking'
				
				accusations[:first].delete_if { |key, value| key == "accused" && value.present? }
				accusations[:second] = { accuser: nil }
			end
		when 'seconder-seeking'
			if accusations[:second][:accuser].present?
				current_round[:phase] = 'accusation'
				accusations[:first][:accused] = nil
				accusations[:second][:accused] = nil
			else
				accusations[:no_seconders] << accusations[:do_not_second]
				accusations[:do_not_second] = nil
				
				if accusations[:no_seconders].length == (game_sessions.length - 1)
					current_round[:phase] = 'winking'
					accusations[:first][:accuser] = nil
					accusations[:no_seconders] = []
				end
			end
		when 'accusation'
			if accusations[:first][:accused].present? && accusations[:second][:accused].present?
				current_round[:phase] = 'challenge'
			end
		end
	end

	def after_started?
		if current_round[:round_number] > 0 && current_turn[:outed].present?
			return true
		elsif current_round[:round_number] > 0 && looking_turn[:looker].present? && looking_turn[:lookee].present?
			return true
		elsif current_round[:phase] == "challenge"
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
				},
				do_not_second: nil,
				no_seconders: []
			},
			looking_turn: { looker: nil, lookee: nil },
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