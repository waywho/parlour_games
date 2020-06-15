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

end
