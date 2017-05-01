# frozen_string_literal: true

class CreatorChannel < ApplicationCable::Channel
  def subscribed
    case role
    when "creator"
      stream_for game
    when "player"
      # The player doesn't get to see events on the creator channel
    end
  end
end
