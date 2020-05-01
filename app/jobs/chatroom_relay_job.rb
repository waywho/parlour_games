class ChatroomRelayJob < ApplicationJob
  queue_as :default

  def perform(chatroom)
    ActionCable.server.broadcast "chatrooms_channel",
	    created_at: chatroom.created_at,
			gameaable_id: chatroom.gameaable_id,
			gameaable_type: chatroom.gameaable_type,
			id: chatroom.id,
			public: chatroom.public,
			topic: chatroom.topic,
			updated_at: chatroom.updated_at,
			user_ids: chatroom.user_ids
  end
end
