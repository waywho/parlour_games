class Chatroom < ApplicationRecord
  belongs_to :gameaable
  has_many :messages, dependent: :destroy
  has_many :users, through: :messages
end
