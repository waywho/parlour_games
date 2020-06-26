require 'active_support/concern'

module ScoreSetup
	extend ActiveSupport::Concern

	included do
		before_create :setup_scores
	end

	private
	def setup_scores
    self.scores = {}
    logger.debug "create scores #{scores}"
    logger.debug "find game #{game}"
    round_keys = game.scoring_rounds.keys
    round_keys.map { |k| scores[k.to_i] = 0 }
	end
end