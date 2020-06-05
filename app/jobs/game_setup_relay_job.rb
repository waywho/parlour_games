class GameSetupRelayJob < ApplicationJob
  queue_as :default

  def perform(game)
    # Do something later
    new_game = Game.find(game.id)
    logger.debug "Job broadcast #{new_game}"
    ActionCable.server.broadcast "game:#{new_game.id}",
      game:  new_game.to_json(include: {teams: { include: [:game_sessions], except: [:game_id, :updated_at]}, users: { only: :name }, players: { only: :name }, game_sessions: { methods: [:team_name], except: [:game_id, :created_at, :updated_at] }}),
      game_sessions: new_game.game_sessions.where(team_id: nil),
      team_numbers: new_game.teams.length
  end
end
