# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @game = Game.find(session[:game_id]) if session[:game_id].present?
  end

  def create
    Game.leave_game(session)
    game = Game.generate!(session)
    redirect_to game_path(game)
  end

  def show
    if session[:game_id] != params[:id].to_i
      redirect_to games_path
      return
    end

    @game = Game.find(session[:game_id])
    @player = @game.players.find_by(id: session[:player_id])
    redirect_to games_path unless @game.active?
  end

  def join
    game = Game.find_active(params[:code])

    unless game
      redirect_to games_path, flash: { danger: "There is no active game with code '#{params[:code]}'" }
      return
    end

    game.leave_previous_game(session)
    game.join_game(params, session)
    redirect_to game_path(game)
  end
end
