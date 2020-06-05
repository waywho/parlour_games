class ChangeUserInMessages < ActiveRecord::Migration[5.2]
  def change
  	add_reference :messages, :speakerable, polymorphic: true
  	reversible do |dir|
  		dir.up { Message.update_all("speakerable_id=user_id, speakerable_type='User'")}
  		dir.down { Message.update_all("user_id=speakerable_id")}
  	end
  	remove_reference :messages, :user, index: true, foreign_key: true
  end
end
