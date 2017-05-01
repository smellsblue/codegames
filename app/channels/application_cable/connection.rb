# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :game
    identified_by :role
    identified_by :player

    def connect
      self.game = Game.active.find_by(id: cookies.signed[:game_id])
      self.role = cookies.signed[:role]

      if game && role == "player"
        self.player = game.players.find_by(id: cookies.signed[:player_id])
      end
    end
  end
end
