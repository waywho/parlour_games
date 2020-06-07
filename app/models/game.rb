class Game < ApplicationRecord
	after_create :create_chatroom
	after_create :generate_slug 

	has_many :game_sessions, dependent: :destroy
	has_many :teams
	has_many :players, through: :game_sessions, source: :playerable, source_type: 'Player'
	has_many :users, through: :game_sessions, source: :playerable, source_type: 'User'

	# has_many :messages, dependent: :destroy
	has_one :chatroom, as: :gameaable
	
	accepts_nested_attributes_for :teams, :game_sessions, allow_destroy: true
	self.inheritance_column = 'name'

	def as_json(options={})
		super(options.merge({ methods: [:name, :hosts, :rounds] }))
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

 	private

 	def create_chatroom
 		Chatroom.create(gameaable: self, topic: "#{self.name}:#{self.id}", public: false)
 	end

 	def generate_slug
 		self.update_attributes(slug: "#{SecureRandom.urlsafe_base64(10)}#{self.id}")
 	end
end
