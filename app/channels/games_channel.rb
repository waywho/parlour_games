class GamesChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "games_channel"
    # current_user.games.each do |game|
    	stream_from "game:#{params[:game]}"
    # end
  end

  def timer_start(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      timer_start: true,
      game_id: data['game_id']
  end

  def guessed_clue(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      guessed_clue: data['guessed_clue'],
      game_id: data['game_id']
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
