class User < ApplicationRecord
	has_one :score, as: :scoreable
	has_many :game_sessions
	has_one :team, through: :game_session
	has_many :games, through: :game_sessions
end
