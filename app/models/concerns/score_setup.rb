require 'active_support/concern'

module ScoreSetup
	extend ActiveSupport::Concern

	included do
		after_create :setup_scores
	end

	def scoring_rounds

	end

	private
	def setup_scores
    self.scores = {}
    logger.debug "create scores #{scores}"
    logger.debug "find game #{game}"
    round_keys = game.scoring_rounds.keys
    round_keys.map { |k| scores[k.to_i] = 0 }
    # self.game.rounds&.each do |key, round|
    #   scores[key.to_i] = 0 if round[:score_round]
    # end
	end
end