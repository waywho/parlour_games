class AddSlugToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :slug, :string
    add_column :games, :password_digest, :string
    add_index :games, :slug, unique: true
  end
end
