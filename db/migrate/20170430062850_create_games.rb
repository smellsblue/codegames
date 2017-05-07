class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.string :code, null: false
      t.integer :current_round_id
      t.boolean :started, default: false, null: false
      t.boolean :finished, default: false, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    create_table :players do |t|
      t.references :game, foreign_key: true, index: true, null: false
      t.string :name, null: false
      t.boolean :active, default: true, null: false
      t.integer :score, default: 0, null: false
      t.timestamps
    end

    create_table :round_data do |t|
      t.string :game_type, null: false
      t.text :data
      t.timestamps
    end

    create_table :rounds do |t|
      t.references :game, foreign_key: true, index: true, null: false
      t.references :round_data, foreign_key: true, index: true, null: false
      t.integer :next_round_id
      t.string :game_type, null: false
      t.string :state, null: false
      t.text :data
      t.timestamps
    end
  end
end
