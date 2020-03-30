class Game < ApplicationRecord
	has_many :game_sessions, dependent: :destroy
	has_many :teams, through: :game_sessions
	has_many :users, through: :game_sessions
	has_many :messages, dependent: :destroy
	has_one :chatroom, as: :gameable
	accepts_nested_attributes_for :teams, :game_sessions, allow_destroy: true
	self.inheritance_column = 'name'

	def as_json(options={})
		super(options.merge({ methods: :name }))
	end
end
