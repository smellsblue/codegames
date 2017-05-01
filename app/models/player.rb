# frozen_string_literal: true

class Player < ApplicationRecord
  class ExistingPlayerError < StandardError
  end

  belongs_to :game
  validates :name, presence: true

  def leave_game
    self.active = false
    save!
    CreatorChannel.broadcast_to(game, event: "player_left", player: self)
  end

  def reactivate
    self.active = true
    save!
  end
end
