class MessagesChannel < ApplicationCable::Channel
  def subscribed
    current_user.chatrooms.all.each do |chatroom|
    	stream_from "chatroom:#{chatroom.id}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
