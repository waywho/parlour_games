class RemoveRuleFromGame < ActiveRecord::Migration[5.2]
  def change
  	remove_column :games, :rule, :string
  	remove_column :games, :description, :text
  	remove_column :games, :avatar, :string
  end
end
