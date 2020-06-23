class GameSession < ApplicationRecord
  belongs_to :game
  belongs_to :playerable, polymorphic: true, optional: true
  belongs_to :team, optional: true
  belongs_to :fishbowl, foreign_key: :game_id, optional: true
  belongs_to :ghost, foreign_key: :game_id, optional: true
  has_many :messages, as: :speakerable
	accepts_nested_attributes_for :messages, allow_destroy: true

  after_create :setup_scores
  after_create :default_player_name

  attr_accessor :deleted

  validates :player_name, presence: true
  after_destroy :mark_as_deleted

  def mark_as_deleted
    self.deleted = true
  end

  def team_name
  	team.name if team.present?
  end

  def class_name
  	self.class.name
  end

	def as_json(options={})
  	super(options.merge({ methods: [:class_name, :name] }))
	end

	def name
		self.player_name
	end

  private

  def setup_scores
    self.scores = {}
    logger.debug "create scores #{scores}"
    logger.debug "find game #{game}"
    self.game.rounds&.each do |key, round|
      scores[key] = 0 if round[:score_round]
    end
    save
  end

  def default_player_name
    if playerable.present? && player_name.nil?
      self.update_attributes(player_name: playerable.name)
      save
    end
  end
end
