class Team < ApplicationRecord
	has_one :score, as: :scoreable
	has_many :game_sessions
	has_many :users, through: :game_sessions
	has_many :game, through: :game_sessions
	has_one :chatroom, as: :gameable
end
