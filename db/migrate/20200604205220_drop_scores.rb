class DropScores < ActiveRecord::Migration[5.2]
  def change
  	add_column :game_sessions, :scores, :jsonb
  end
end
