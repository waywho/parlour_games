class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.boolean :admin
      t.string :avatar

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :admin
  end
end
