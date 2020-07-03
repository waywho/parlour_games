class AddOptionsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :options, :jsonb

  end
end
