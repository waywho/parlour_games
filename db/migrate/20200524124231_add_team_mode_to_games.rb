class AddTeamModeToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :team_mode, :boolean, default: false
  end
end
