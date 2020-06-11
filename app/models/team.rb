class Team < ApplicationRecord
	has_many :game_sessions
	accepts_nested_attributes_for :game_sessions
	has_many :users, through: :game_sessions
	belongs_to :game
	has_one :chatroom, as: :gameable
	before_create :setup_scores

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

	def setup_scores
    self.scores = {}
    logger.debug "create scores #{scores}"
    logger.debug "find game #{game}"
    self.game&.rounds&.each do |key, round|
      scores[key] = 0 if round[:score_round]
    end
  end
end



