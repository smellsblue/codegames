class RoundsController < ApplicationController
  def answer
    round = Round.answer(session, params)
    redirect_to game_path(round.game)
  rescue DisplayError => e
    redirect_to game_path(Round.find(params[:id]).game), flash: { danger: e.message }
  end

  def start
    round = Game.start_round(session, params)
    redirect_to game_path(round.game)
  end

  def finish
    round = Round.finish(session, params)
    redirect_to game_path(round.game)
  end
end
