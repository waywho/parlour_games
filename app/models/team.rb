class Team < ApplicationRecord
	has_one :score, as: :scoreable
	belongs_to :game_session
	has_many :users, through: :game_sessions
end
