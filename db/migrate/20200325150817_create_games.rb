class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :name
      t.jsonb :pieces
      t.string :play
      t.references :game_session, foreign_key: true

      t.timestamps
    end
    add_index :games, :name
    add_index :games, :play
  end
end
