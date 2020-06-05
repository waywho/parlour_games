class CreatePlayers < ActiveRecord::Migration[5.2]
  def change
    create_table :players do |t|
      t.string :name
      t.string :ip_address

      t.timestamps
    end
    add_index :players, :ip_address
  end
end
