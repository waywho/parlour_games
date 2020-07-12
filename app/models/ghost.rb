require 'rest-client'

class Ghost < Game
	before_create :game_setup
	store :set, accessors: [:play_word, :word_definition, :played_words, :current_round, :player_ghosts, :rounds_played], coder: JSON
	store :turn_order, accessors: [:current_turn, :challenge, :players_gone], coder: JSON
	store :options, accessors: [:language, :team_mode, :min_word_length], coder: JSON
	before_update :start_game, if: :started_changed?
	before_update :play, if: :after_started?

	ROUNDS = {
		1  => { name: "1", score_round: true }
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

	CHALLENGE_TYPES = ['spelling', 'word_complete']

	GHOST_ARRY = ['g', 'h', 'o', 's', 't']

	def start_game
		if started
			set_up_player_ghosts
		end
		current_turn[:nominated_player] = game_sessions.first.id
		current_round[:round_number] = 1
	end

	def play
		logger.debug "run play #{play_word}"
		if !current_round[:completed] && play_word.length >= min_word_length && challenge[:type].present?
			previous_player_id = turn_order[:current_turn][:previous_player].to_s

			joined_play_word = play_word.join
			case challenge[:type]
			when 'word_complete'
				# last nominated player lose turn
				if word_challenge(joined_play_word)
					
					lost_turn(previous_player_id)
					lost_round?(previous_player_id)
				else
			
					lost_turn(challenge[:challenger].to_s)
					lost_round?(challenge[:challenger].to_s)
				end

			when 'spelling'
				# challenger lose turn
				if spelling_challenge(joined_play_word)
					lost_turn(challenge[:challenger].to_s)
					lost_round?(challenge[:challenger].to_s)
				else
					lost_turn(previous_player_id)
					lost_round?(previous_player_id)
				end
			end

			challenge[:type] = nil

		elsif current_round[:completed] && !ended
			next_round
			current_turn[:previous_player] = nil
			next_turn
		else
			current_turn[:previous_player] = current_turn[:nominated_player]
			next_turn
		end
	end

	def next_round
		set_up_player_ghosts
		self.challenge = {
				type: nil,
				challenger: nil,
				results: nil
			}
		self.play_word = []
		current_round[:round_number] += 1
		current_round[:completed] = false
		rounds_played[current_round[:round_number]] = { name: current_round[:round_number].to_s, score_round: true }
		game_sessions.each do  |session|
			session.scores[current_round[:round_number].to_s] = 0
			session.save		
		end
	end

	def word_challenge(word)
		result = RestClient.get "https://api.datamuse.com/words?sp=#{word}&md=d"
		result_array = JSON.parse(result)

		if result_array.empty?
			return false
		else
			result_json = result_array.first
			exact_word = result_json["word"] == word
			has_meaning = result_json["defs"].present?
	
			if exact_word && has_meaning
				challenge[:results] = {
					word: result_json["word"],
					outcome: result_json["defs"]
				}
				return true
			else
				challenge[:results] = {
					word: word,
					outcome: ["This word is not complete, cannot find word with meaning."]
				}
				return false
			end
		end
	end

	def spelling_challenge(word)

		results = RestClient.get "https://api.datamuse.com/words?sp=#{word}*"
		logger.debug "challenge results #{results}"
		results = JSON.parse(results)
		challenge_arry = results&.map { |w| w["word"] }
		
		if results.length > 1
			challenge[:results] = {
				word: word,
				outcome: challenge_arry
			}
			return true
		else
			challenge[:results] = {
				word: word,
				outcome: ["No possible word from this spelling."]
			}
			return false
		end
	end

	def set_up_player_ghosts
		game_sessions.each do |session|
			player_ghosts[session.id] = []
		end
	end

	def after_started?
		logger.debug "#{current_round[:round_number]} is larger than 0: #{current_round[:round_number] > 0}"
		return current_round[:round_number] > 0
	end

	def lost_turn(player_id)
		lost_player_name = game_sessions.find_by_id(player_id.to_i).player_name
		challenge[:results][:outcome].unshift("#{lost_player_name} lost.\n")

		ghost_arry = GHOST_ARRY
		ghost_length = player_ghosts[player_id].length
		player_ghosts[player_id].push(ghost_arry[ghost_length])
		played_words << play_word.join
		self.play_word = []
	end

	def lost_round?(player_id)
		ghost_arry = GHOST_ARRY
		if player_ghosts[player_id].length == ghost_arry.length	
			logger.debug "ghost array #{ghost_arry.length}"
			game_sessions.each do |session|
				logger.debug "session #{session} #{session.scores[current_round[:round_number].to_s]}"
				if session.scores[current_round[:round_number].to_s].present?
					session.scores[current_round[:round_number].to_s] += 1 if session.id != current_turn[:nominated_player]
				else
					session.scores[current_round[:round_number].to_s] = 1 if session.id != current_turn[:nominated_player]
				end
				session.save
			end
			current_round[:completed] = true
			return true
		else
			return false
		end
	end

	private

	def game_setup
		self.turn_order = {
			current_turn: {
				nominated_player: nil,
				previous_player: nil
			},
			challenge: {
				type: nil,
				challenger: nil,
				results: nil
			},
			players_gone: [],
		}
		self.set = {
			play_word: [],
			played_words: [],
			current_round: {
				round_number: 0,
				completed: false
			},
			player_ghosts: {},
			rounds_played: {
				1 => { name: "1", score_round: true }
			}
		}
		self.options = {
			language: 'English',
			team_mode: false,
			min_word_length: 2
		}
	end
end