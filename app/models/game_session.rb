class GameSession < ApplicationRecord
  belongs_to :game
  belongs_to :playerable, polymorphic: true, optional: true
  belongs_to :team, optional: true
  belongs_to :fish_bowl, foreign_key: :game_id
  has_many :messages, as: :speakerable
	accepts_nested_attributes_for :messages, allow_destroy: true

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

  def setup_score
    scores = {}
    game.rounds&.each do |key, round|
      score[key] = 0 if round[:score_round]
    end
  end
end
