class MessageRelayJob < ApplicationJob
  queue_as :default

  def perform(message)
    ActionCable.server.broadcast "chatroom:#{message.chatroom.id}",
      content: message.content,
      user: { name: message.user.name },
      created_at: message.created_at,
      chatroom_id: message.chatroom.id
  end
end
