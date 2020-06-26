class Team < ApplicationRecord
	has_many :game_sessions
	accepts_nested_attributes_for :game_sessions
	has_many :users, through: :game_sessions, class_name: 'User'
	belongs_to :game
	has_one :chatroom, as: :gameaable
	include ScoreSetup

	def as_json(options={})
  	super(options.merge({ methods: [:scores] }))
	end

	private

	# def scores
	# 	if game_sessions.present?
	# 		total = game_sessions.map(&:scores).each_with_object({}) do |el, sum|
	# 			# logger.debug "object #{el}"
	# 			# logger.debug "sum #{sum}"
	# 			el&.each { |key, value| sum[key].present? ? sum[key] += value : sum[key] = value}
	# 		end
	# 	end
	# 	total
	# end
end



