class AddSlugToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :password_digest, :string
  end
end
