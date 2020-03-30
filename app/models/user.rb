class User < ApplicationRecord
	has_one :score, as: :scoreable
	has_many :game_sessions
	accepts_nested_attributes_for :game_sessions, allow_destroy: true
	has_many :teams, through: :game_sessions
	has_many :games, through: :game_sessions
	has_many :chatrooms, through: :messages
	has_many :messages

	has_secure_password
	validates :email, presence: true, uniqueness: true
	validates :name, presence: true, uniqueness: true
end
