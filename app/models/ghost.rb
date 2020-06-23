require 'rest-client'

class Ghost < Game
	before_create :game_setup
	before_update :start_game, if: :started_changed?
	before_update :play, if: :after_started?
	before_update :lost_turn, if: :lost_challenge

	ROUNDS = {
		1 => { name: "1", score_round: true }
	}
	DESCRIPTION = ""
	LANGUAGES = {
		"English": "en",
		"Hindi": "hi",
		"Spanish": "es",
		"French": "fr",
		"Japanese": "ja",
		"Russian": "ru",
		"German": "de",
		"Italian": "it",
		"Korean": "ko",
		"Brazilian Portuguese": "pt-BR",
		"Arabic": "ar",
		"Turkish": "tr"
	}

	GHOST_ARRY = ['g', 'h', 'o', 's', 't']

	def start_game
		if started
			set_up_player_ghosts
		end
		set["current_turn"]["nominated_player"] = game_sessions.first.id
		set["current_round"]["round_number"] = 1
	end

	def play
		# check if play_word is a word
		# lang = LANGUAGES[set["options"]["language"]]
		logger.debug "run play #{set["play_word"]}"
		if set["current_round"]["completed"] == false && set["play_word"].length > set["options"]["min_word_length"]
			result = RestClient.get "https://api.datamuse.com/words?sp=#{set["play_word"].join}&md=d"
			ghost_arry = GHOST_ARRY
			result_array = JSON.parse(result)
			logger.debug "finding results #{result}"
			logger.debug "finding array #{result_array} #{result_array.nil?}"
			logger.debug "ghost array #{ghost_arry}"
			
			challenge

			if result_array.empty?
				logger.debug "no result"
				exact_word = false
				has_meaning = false	
			else
				logger.debug "i got here"
				result_json = result_array.first
				logger.debug "finding results #{result_json}"
				logger.debug "finding word #{result_json["word"]}"
				logger.debug "finding definition #{result_json["defs"]}"
				exact_word = result_json["word"] == set["play_word"].join
				has_meaning = result_json["defs"].present?
				set["word_definition"] = result_json if exact_word && has_meaning
			end

			logger.debug "escape to word"
			
			if exact_word && has_meaning
				logger.debug "Results found"
				
				# if player_word is a word, nominated_player looses, gets a letter
				logger.debug "nominated player #{set["current_turn"]["nominated_player"]}"

				player_id = set["current_turn"]["nominated_player"].to_s

				ghost_length = set["player_ghosts"][player_id].length
				logger.debug "ghost_length #{ghost_length}"
				
				
				if ghost_length < ghost_arry.length
					logger.debug "got a letter"
					set["player_ghosts"][player_id].push(ghost_arry[ghost_length])

					logger.debug "save played word"
					set["played_words"] << set["play_word"].join
					logger.debug "reset played word"
					set["play_word"] = []
					logger.debug "#{player_id} player ghosts #{set["player_ghosts"][player_id]}"
					
					# if nominated player has "ghost", round ends, turn stays the same
					lost_round(player_id)
				else
					next_turn
				end
			else
				next_turn
			end
		elsif set["current_round"]["completed"] && !ended
			next_round
		else
			next_turn
		end
	end

	def next_round
		set_up_player_ghosts
		# set["rounds"] << set["current_round"]["round_number"]
		set["word_definition"] = nil
		set["play_word"] = []
		set["current_round"]["completed"] = false
		set["rounds"][set["current_round"]["round_number"]] = { name: set["current_round"]["round_number"].to_s, score_round: true }
		game_sessions.each do  |session|
			session.scores[set["current_round"]["round_number"].to_s] = 0
			session.save		
		end
		next_turn
	end

	def challenge
		results = RestClient.get "https://api.datamuse.com/words?sp=#{set["play_word"].join}*"
		logger.debug "challenge results #{results}"
		results = JSON.parse(results)
		challenge_arry = results&.map { |w| w["word"] }
		set["challenge_results"] = challenge_arry
	end

	def set_up_player_ghosts
		game_sessions.each do |session|
			set["player_ghosts"][session.id] = []
		end
	end

	def after_started?
		logger.debug "#{set["current_round"]["round_number"]} is larger than 0: #{set["current_round"]["round_number"] > 0}"
		return set["current_round"]["round_number"] > 0 && set["current_round"]["challenge_lost"] == false
	end

	def lost_challenge
		return set["current_round"]["challenge_lost"]
	end

	def lost_turn(player_id)
		ghost_arry = GHOST_ARRY
		player_id = set["current_turn"]["nominated_player"].to_s
		set["player_ghosts"][player_id].push(ghost_arry[ghost_length])
		set["played_words"] << set["play_word"].join
		set["play_word"] = []
		lost_round(player_id)
	end

	def lost_round(player_id)
		ghost_arry = GHOST_ARRY
		if set["player_ghosts"][player_id].length == ghost_arry.length	
			logger.debug "ghost array #{ghost_arry.length}"
			game_sessions.each do |session|
				logger.debug "session #{session} #{session.scores[set["current_round"]["round_number"].to_s]}"
				if session.scores[set["current_round"]["round_number"].to_s].present?
					session.scores[set["current_round"]["round_number"].to_s] += 1 if session.id != set["current_turn"]["nominated_player"]
				else
					session.scores[set["current_round"]["round_number"].to_s] = 1 if session.id != set["current_turn"]["nominated_player"]
				end
				session.save
			end
			set["current_round"]["completed"] = true
		else
			next_turn
		end
	end

	def rounds
		set["rounds"]
	end

	private

	def game_setup
		self.set = {
			play_word: [],
			word_definition: nil,
			challenge_results: nil,
			played_words: [],
			current_round: {
				round_number: 0,
				completed: false
			},
			current_turn: {nominated_player: nil, challenge_lost: false},
			players_gone: [],
			player_ghosts: {},
			options: {
				language: 'English',
				team_mode: false,
				min_word_length: 2
			},
			rounds: {
				1 => { name: "1", score_round: true }
			}
		}
	end
end