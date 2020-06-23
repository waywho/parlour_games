class Message < ApplicationRecord
  belongs_to :speakerable, polymorphic: true
  belongs_to :chatroom
  validates :content, presence: true
end
