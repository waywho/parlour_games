class Game < ApplicationRecord
	after_create :create_chatroom

	has_many :game_sessions, dependent: :destroy
	has_many :teams, dependent: :destroy
	has_many :players, through: :game_sessions, source: :playerable, source_type: 'Player'
	has_many :users, through: :game_sessions, source: :playerable, source_type: 'User'

	# has_many :messages, dependent: :destroy
	has_one :chatroom, as: :gameaable
	
	accepts_nested_attributes_for :teams, :game_sessions, allow_destroy: true
	self.inheritance_column = 'name'

	ROUNDS = { }

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


 	def next_turn
 		logger.debug "this problem?"
		logging("Game Step 3", "Next turn, #{self.set}")
		logger.debug "not the problem"
		# reset turn passing number and completed
		set["current_turn"]["passed"] = 0 if set["current_turn"]["passed"].present?
		set["current_turn"]["completed"] = false
		if team_mode
			# find current team
			team_number = set["current_turn"]["team"]
			logging("Game Step 3.1", "Last Team Order, #{team_number}")

			# put last player into 'gone' list according to team
			set["players_gone"][team_number] << set["current_turn"]["nominated_player"] if set["current_turn"]["nominated_player"].present?

			# check if we are at the end of the teams
			if team_number == teams.length
				set["current_turn"]["team"] = 1
			else
				set["current_turn"]["team"] += 1
			end
		else
			# put last player into 'gone' list without team
			set["players_gone"] << set["current_turn"]["nominated_player"] if set["current_turn"]["nominated_player"].present?
		end
		next_player
	end

	def next_player
		logging("Game Step 4", "Next player #{self.set}")


		if team_mode
			new_team_number = set["current_turn"]["team"]
			logging("Game Step 4.1", "Team order #{new_team_number}")

			new_team = teams.where(order: new_team_number).take

			logging("Game Step 4.2", "Found current team #{new_team}, #{self.set}")
			
			players = new_team.game_sessions.map(&:id)

			logging("Game Step 4.3", "Current team members #{players}")
			logging("Game Step 4.4", "current team number #{new_team_number}")
			logging("Game Step 4.4", "Current team gone players #{set['players_gone'][new_team_number]}")

			left_players = players - set["players_gone"][new_team_number]

		else
			players = game_sessions.map(&:id)

			logging("Game Step 4.1", "current team members #{players}")
			left_players = players - set["players_gone"]
		end
		
		if left_players.empty? && team_mode
			left_players = players
			set["players_gone"][new_team_number] = []
		elsif left_players.empty? && !team_mode
			left_players = players
			set["players_gone"] = []
		end

		set["current_turn"]["nominated_player"] = left_players.first

		logging("Game Step 4.5", "Found next player #{left_players.first}, #{self.set}")
	end

	private
	def logging(game_step, message)
		logger.tagged("#{self.name}") { logger.tagged(game_step)  { logger.debug(message) } }
	end

 	def create_chatroom
 		Chatroom.create(gameaable: self, topic: "#{self.name}:#{self.id}", public: false)
 	end
end
