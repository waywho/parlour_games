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

 	private

 	def create_chatroom
 		Chatroom.create(gameaable: self, topic: "#{self.name}:#{self.id}", public: false)
 	end


 	def next_turn
		logging("Game Step 3", "Next turn, #{self.set}")
		# reset turn passing number and completed
		set["current_turn"]["passed"] = 0
		set["current_turn"]["completed"] = false
		if team_mode
			# find current team
			team_number = set["current_turn"]["team"]
			logging("Game Step 3.1", "Last Team Order, #{team_number}")

			# put last player into 'gone' list according to team
			set["gone_players"][team_number.to_s] << set["current_turn"]["nominated_player"] if set["current_turn"]["nominated_player"].present?

			# check if we are at the end of the teams
			if team_number == teams.length
				set["current_turn"]["team"] = 1
			else
				set["current_turn"]["team"] += 1
			end
		else
			# put last player into 'gone' list without team
			set["gone_players"] << set["current_turn"]["nominated_player"] if set["current_turn"]["nominated_player"].present?
		end
		next_player
	end

	def next_player
		logging("Game Step 4", "Next player #{self.set}")


		if team_mode
			current_team_number = set["current_turn"]["team"].to_s
			logging("Game Step 4.1", "Team order #{current_team_number}")

			current_team = teams.where(order: current_team_number.to_i).take

			logging("Game Step 4.2", "Found current team #{current_team}, #{self.set}")
			
			players = current_team.game_sessions.map(&:id)

			logging("Game Step 4.3","Current team members #{players}")

			logging("Game Step 4.4","Current team gone players #{set["gone_players"][current_team_number]}")
			left_players = players - set["gone_players"][current_team_number]
		else
			players = game_sessions.map(&:id)

			logging("Game Step 4.1", "current team members #{players}")
			left_players = players - set["gone_players"]
		end
		
		if left_players.empty? && team_mode
			left_players = players
			set["gone_players"][current_team_number] = []
		elsif left_players.empty?
			left_players = players
			set["gone_players"] = []
		end

		self.set["current_turn"]["nominated_player"] = left_players.first

		logging("Game Step 4.5", "Found next player #{left_players.first}, #{self.set}")
	end

	private
	def logging(game_step, message)
		logger.tagged("#{self.name}") { logger.tagged(game_step)  { logger.debug(message) } }
	end

end
