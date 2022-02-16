class AddInteractionsToGame < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :interactions, :jsonb, using: :gin

    Game.find_each do |game|
      turn_order = game.turn_order
      case game.name
      when "Ghost"
        game.set
        game.interactions = {
          challenge: turn_order.delete(:challenge),
          played_words: game.set.delete(:played_word),
          play_word: game.set.delete(:play_word)
        }
        game.turn_order = turn_order
      when "Fishbowl"
        game.set["guessed_clues"]
        game.interactions = {
          current_clue: game.set.delete(:current_clue),
          guessed_clues: game.set.delete(:guessed_clues),

        }
      when "WinkMurder"
        game.interactions = {
          accusations: game.turn_order.delete(:accusations)
        }
      end
      game.save
    end
  end
end
