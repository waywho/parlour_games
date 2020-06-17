require 'rest-client'

class Ghost < Game
	before_create :game_setup
	before_update :start_game, if: :started_changed?
	before_update :play, if: :after_started?
	ROUNDS = nil
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
		"Brazilian Portuguese":  "pt-BR",
		"Arabic": "ar",
		"Turkish": "tr"
	}


	def start_game
		if started
			set_up_player_ghosts
		end
		set["current_round"]["round_number"] = 1
	end

	def play
		# check if play_word is a word
		lang = LANGUAGES[set["options"]["language"]]

		if set["current_round"]["completed"] == false
			result = RestClient.get "https://api.datamuse.com/words?sp=#{set["play_word"].join}&md=d"
			ghost_arry = ['g', 'h', 'o', 's', 't']
			if result.length > 0
				# if player_word is a word, nominated_player loose gets a letter
				ghost_length = set["player_ghosts"][set["current_turn"]["nominated_player"]].length
				if ghost_length < ghost_arry.length
					set["player_ghosts"][set["current_turn"]["nominated_player"]].push(ghost_arry[ghost_length])
					next_turn
				else
				# if nominated player has "ghost", round ends
					set["current_round"]["completed"] = true
				end
			end
		elsif set["current_round"]["completed"] && !ended
			next_round
		end

	end

	def next_round
		set_up_player_ghosts
		set["word_definition"] = nil
		set["play_word"] = []
		set["current_round"]["round_number"] += 1
		set["current_round"]["completed"] = false
	end

	def set_up_player_ghosts
		game_sessions.each do |session|
			set["player_ghosts"][session.id] = []
		end
	end

	def after_started?
		logger.debug "#{set["current_round"]["round_number"]} is it larger than 0 #{set["current_round"]["round_number"] > 0}"
		return set["current_round"]["round_number"] > 0 && set["play_word"].length > 0
	end

	private

	def game_setup
		self.set = {
			play_word: [],
			word_definition: nil,
			played_words: [],
			current_round: {
				round_number: 0,
				completed: false
			},
			current_turn: {nominated_player: nil},
			gone_players: [],
			player_ghosts: {},
			options: {
				language: 'English',
				team_mode: false
			}
		}
	end
end