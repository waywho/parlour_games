class Game < ApplicationRecord
	has_many :game_sessions, dependent: :destroy
	has_many :teams, dependent: :destroy
	has_many :players, through: :game_sessions, source: :playerable, source_type: 'Player'
	has_many :users, through: :game_sessions, source: :playerable, source_type: 'User'

	# has_many :messages, dependent: :destroy
	has_one :chatroom, as: :gameaable
	
	accepts_nested_attributes_for :teams, :game_sessions, allow_destroy: true
	self.inheritance_column = 'name'

	include TurnBehaviour
	
	after_create :create_chatroom
	before_create :game_setup
	store :turn_order, accessors: [:current_turn, :players_gone], coder: JSON
	before_update :setup_teams, if: :started_changed?
	
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
