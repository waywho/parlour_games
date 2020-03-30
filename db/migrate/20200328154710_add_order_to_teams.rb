class AddOrderToTeams < ActiveRecord::Migration[5.2]
  def change
    add_column :teams, :order, :integer
  end
end
