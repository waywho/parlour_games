class User < ApplicationRecord
	has_many :game_sessions, as: :playerable
	accepts_nested_attributes_for :game_sessions, allow_destroy: true
	has_many :teams, through: :game_sessions
	has_many :games, through: :game_sessions
	has_many :fishbowls, through: :game_sessions
	
	has_many :messages, as: :speakerable
	accepts_nested_attributes_for :messages, allow_destroy: true
	has_many :chatroom_users
	has_many :chatrooms, through: :chatroom_users

	has_secure_password
	validates :email, presence: true, uniqueness: true
	validates :name, presence: true, uniqueness: true

	def to_token_payload
    # Returns the payload as a hash
    { sub: id, id: id, name: name, email: email, class_name: self.class.name }
	end
end
