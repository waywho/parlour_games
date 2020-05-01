class ChatroomsChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    # current_user.chatrooms.all.each do |chatroom|
    # 	stream_from "chatroom:#{chatroom.id}"
    # end

    stream_from "chatrooms_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
