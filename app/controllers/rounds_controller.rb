class RoundsController < ApplicationController
  def start
    round = Game.start_round(session, params)
    redirect_to game_path(round.game)
  end
end
