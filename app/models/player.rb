# frozen_string_literal: true

class Player < ApplicationRecord
  class ExistingPlayerError < StandardError
  end

  belongs_to :game
  validates :name, presence: true

  def self.active
    where(active: true)
  end

  def as_json(options = {})
    super.tap do |result|
      result[:round_state] = round_state
    end
  end

  def leave_game
    self.active = false
    save!
    CreatorChannel.broadcast_to(game, event: "player_left", player: self)
  end

  def reactivate
    self.active = true
    save!
  end

  def round_state
    if game.active_round?
      game.current_round.game_object.player_state(self)
    else
      "none"
    end
  end
end
