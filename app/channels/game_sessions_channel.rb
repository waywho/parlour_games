class GameSessionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "game_session:#{params[:game]}"
    stream_from "game_session:general"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
