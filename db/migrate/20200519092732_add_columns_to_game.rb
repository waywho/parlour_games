class AddColumnsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :started, :boolean, default: false
    add_column :games, :ended, :boolean, default: false
  end
end
