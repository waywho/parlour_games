class CreateGameSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :game_sessions do |t|
      t.references :game, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :host, default: false

      t.timestamps
    end
    add_index :game_sessions, :host
  end
end
