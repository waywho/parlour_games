class GameSessionRelayJob < ApplicationJob
  queue_as :default

  def perform(session)
    ActionCable.server.broadcast "game_session:#{session.game_id}",
      host: session&.host,
      id: session&.id,
      game: { name: session.game.name },
      invitation_accepted: session&.invitation_accepted,
      player_name: session&.player_name,
      team_name: session&.team_name,
      deleted: session&.deleted
  end
end
