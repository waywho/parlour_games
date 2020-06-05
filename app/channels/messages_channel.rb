class MessagesChannel < ApplicationCable::Channel
  def subscribed
  	if current_user.present?
	    current_user.chatrooms.each do |chatroom|
	    	stream_from "chatroom:#{chatroom.id}"
	    end
  	end
    stream_from "chatroom:#{params[:chatroom]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end
end
