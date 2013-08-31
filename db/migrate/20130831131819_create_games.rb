class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :user_one
      t.string :user_two

      t.timestamps
    end
  end
end
