# frozen_string_literal: true

class PlayerChannel < ApplicationCable::Channel
  def subscribed
    case role
    when "creator"
      stream_for game
    when "player"
      stream_for game
      stream_for player
    end
  end
end
