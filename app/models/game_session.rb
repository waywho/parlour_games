class GameSession < ApplicationRecord
  belongs_to :game
  belongs_to :user
  belongs_to :team
end
