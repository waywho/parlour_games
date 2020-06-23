class Chatroom < ApplicationRecord
  belongs_to :gameaable, polymorphic: true, optional: true
  has_many :messages
  has_many :chatroom_users, dependent: :destroy
  has_many :users, through: :chatroom_users

  validates :topic, presence: true, uniqueness: true

  def user_ids
  	users.map(&:id)
  end
end
