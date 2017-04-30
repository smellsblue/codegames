# frozen_string_literal: true

class GamesController < ApplicationController
  def new
  end

  def create
    game = Game.generate!
    session[:game_id] = game.id
    redirect_to game_path(game)
  end

  def show
    if session[:game_id] != params[:id].to_i
      redirect_to new_game_path
      return
    end

    @game = Game.find(session[:game_id])
  end

  def join
  end
end
