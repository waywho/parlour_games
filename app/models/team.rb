class Team < ApplicationRecord
	has_many :game_sessions
	accepts_nested_attributes_for :game_sessions
	has_many :users, through: :game_sessions
	has_many :game, through: :game_sessions
	has_one :chatroom, as: :gameable

	def as_json(options={})
  	super(options.merge({ methods: [:score] }))
	end

	def score
		game_sessions.sum(&:score)
	end
end
