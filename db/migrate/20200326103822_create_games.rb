class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games, id: :uuid do |t|
      t.string :name
      t.jsonb :set
      t.text :description
      t.string :rule
      t.string :avatar

      t.timestamps
    end
    add_index :games, :name
    add_index :games, :rule
  end
end
