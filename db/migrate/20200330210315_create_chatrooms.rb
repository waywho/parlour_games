class CreateChatrooms < ActiveRecord::Migration[5.2]
  def change
    create_table :chatrooms do |t|
      t.references :gameaable, polymorphic: true, type: :uuid
      t.string :topic
      t.boolean :public, default: true

      t.timestamps
    end
    add_index :chatrooms, :topic
    add_index :chatrooms, :public
  end
end
