# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @game = Game.find(session[:game_id]) if session[:game_id].present?
  end

  def create
    game = Game.generate!
    session[:game_id] = game.id
    redirect_to game_path(game)
  end

  def show
    if session[:game_id] != params[:id].to_i
      redirect_to games_path
      return
    end

    @game = Game.find(session[:game_id])
    redirect_to games_path unless @game.active?
  end

  def join
    game = Game.active.with_code(params[:code]).first

    unless game
      redirect_to games_path, flash: { danger: "There is no active game with code '#{params[:code]}'" }
      return
    end
  end
end
