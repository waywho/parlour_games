class GamesChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "games_channel"
    # current_user.games.each do |game|
    	stream_from "game:#{params[:game]}"
    # end
  end

  def turn_start(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      turn_start: true,
      game_id: data['game_id']
  end

  def current_clue(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      current_clue: data['current_clue'],
      game_id: data['game_id']
  end

  def guessed_clue(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      guessed_clue: data['guessed_clue'],
      game_id: data['game_id']
  end

  def passed(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      passed: data['passed'],
      game_id: data['game_id']
  end

  def looking(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      looking: data['looking'],
      looker: data['looker']
  end

  def killing(data)
    ActionCable.server.broadcast "game:#{data['game_id']}",
      killing: true,
      killer: data['killer']
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
