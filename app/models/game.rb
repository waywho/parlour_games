class Game < ApplicationRecord
	after_create :create_chatroom
	before_create :game_setup
	store :turn_order, accessors: [:current_turn, :players_gone], coder: JSON
	before_update :setup_teams, if: :started_changed?
	has_many :game_sessions, dependent: :destroy
	has_many :teams, dependent: :destroy
	has_many :players, through: :game_sessions, source: :playerable, source_type: 'Player'
	has_many :users, through: :game_sessions, source: :playerable, source_type: 'User'

	# has_many :messages, dependent: :destroy
	has_one :chatroom, as: :gameaable
	
	accepts_nested_attributes_for :teams, :game_sessions, allow_destroy: true
	self.inheritance_column = 'name'
	
	ROUNDS = {}
	DESCRIPTION = ""

	def as_json(options={})
		super(options.merge({ methods: [:name, :hosts, :rounds, :description] }))
	end

	def user_ids
  	users.map(&:id)
 	end

 	def hosts
 		game_sessions.where(host: true)
 	end

 	def rounds
		self.class::ROUNDS
	end

	def description
		self.class::DESCRIPTION
	end

	def scoring_rounds
		self.rounds&.select { |k, v| v[:score_round] }
	end

 	def next_turn
		logging("Game Step 3", "Next turn, #{self.set}")
		# reset turn passing number and completed
		current_turn[:passed] = 0 if current_turn[:passed].present?
		current_turn[:completed] = false
		if team_mode
			# find current team
			team_number = current_turn[:team]
			logging("Game Step 3.1", "Last Team Order, #{team_number}")

			# put last player into 'gone' list according to team
			players_gone[team_number.to_s] << current_turn[:nominated_player] if current_turn[:nominated_player].present?

			# check if we are at the end of the teams
			if team_number == teams.length
				current_turn[:team] = 1
			else
				current_turn[:team] += 1
			end
		else
			# put last player into 'gone' list without team
			players_gone << current_turn[:nominated_player] if current_turn[:nominated_player].present?
		end
		next_player
	end

	def next_player
		logging("Game Step 4", "Next player #{self.set}")

		if team_mode
			new_team_number = current_turn[:team]
			logging("Game Step 4.1", "Team order #{new_team_number}")

			new_team = teams.where(order: new_team_number).take

			logging("Game Step 4.2", "Found current team #{new_team}, #{self.set}")
			
			players = new_team.game_sessions.sort_by(&:id).map(&:id)

			logging("Game Step 4.3", "Current team members #{players} \n Current team number #{new_team_number} \n Current team gone players #{players_gone[new_team_number.to_s]}")

			if players_gone[new_team_number.to_s].present?
				left_players = players - players_gone[new_team_number.to_s]
			else
				left_players = players
			end

		else
			players = game_sessions.sort_by(&:id).map(&:id)

			logging("Game Step 4.1", "current team members #{players}")

			if players_gone.present?
				left_players = players - players_gone
			else
				left_players = players
			end
		end
		
		if left_players.empty? && team_mode
			left_players = players
			players_gone[new_team_number.to_s] = []
		elsif left_players.empty? && !team_mode
			left_players = players
			self.players_gone = []
		end

		current_turn[:nominated_player] = left_players.first

		logging("Game Step 4.5", "Found next player #{left_players.first}, #{self.set}")
	end

	protected

	def logging(game_step, message)
		logger.tagged("#{self.name}") { logger.tagged(game_step)  { logger.debug(message) } }
	end

	private

 	def create_chatroom
 		Chatroom.create(gameaable: self, topic: "#{self.name}:#{self.id}", public: false)
 	end

 	def setup_teams
 		if started
	 		if teams.present? && team_mode
					self.players_gone = {}
					teams.each_with_index do |team, index|
						team.update_attributes(order: (index + 1))
						self.players_gone[index + 1] = []
					end
				else
					self.players_gone = []
			end
		end
 	end

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
				players_gone: nil,
 			}
			# self.set = {
			# 	current_round: { 
			# 		round_number: nil,
			# 		completed: false
			# 	}
			# }
	end
end
