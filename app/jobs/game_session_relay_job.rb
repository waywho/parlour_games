class GameSessionRelayJob < ApplicationJob
  queue_as :default

  def perform(session)
    ActionCable.server.broadcast "game_session:#{session.game_id}",
      host: session.host,
      id: session.id,
      invitation_accepted: session.invitation_accepted,
      player_name: session.player_name,
      team_name: session.team_name
  end
end
