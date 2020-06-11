class AddScoresToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :scores, :jsonb
  end
end
