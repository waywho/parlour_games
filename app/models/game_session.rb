class GameSession < ApplicationRecord
  belongs_to :game
  belongs_to :playerable, foreign_key: :playerable_id, polymorphic: true, optional: true
  belongs_to :team, foreign_key: :team_id, optional: true
  belongs_to :fishbowl, foreign_key: :game_id, optional: true
  belongs_to :ghost, foreign_key: :game_id, optional: true
  has_many :messages, as: :speakerable
	accepts_nested_attributes_for :messages, allow_destroy: true

  before_validation :default_player_name, on: :create
  include ScoreSetup

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

  def default_player_name
    if playerable.present? && player_name.nil?
      self.update_attributes(player_name: playerable.name)
    end
  end
end
