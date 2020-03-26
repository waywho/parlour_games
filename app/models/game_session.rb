class GameSession < ApplicationRecord
	has_one :game
	has_many :teams
	has_and_belongs_many :users
end
