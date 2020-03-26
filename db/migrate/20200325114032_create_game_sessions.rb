class CreateGameSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :game_sessions do |t|
      t.string :name
      t.text :description
      t.text :rules
      t.string :avatar

      t.timestamps
    end
  end
end
