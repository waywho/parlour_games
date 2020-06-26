class AddTurnsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :turn_order, :jsonb, using: :gin
  end
end
