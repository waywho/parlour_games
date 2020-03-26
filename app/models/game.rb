class Game < ApplicationRecord
	has_many :game_sessions
	has_many :teams, through: :game_sessions
	has_many :users, through: :game_sessions
end
