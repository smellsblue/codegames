# frozen_string_literal: true

class GamesController < ApplicationController
  def index
    @game = Game.find(session[:game_id]) if session[:game_id].present?
  end

  def create
    Game.leave_game(session, cookies)
    game = Game.generate!(session, cookies)
    redirect_to game_path(game)
  end

  def show
    if session[:game_id] != params[:id].to_i
      redirect_to games_path
      return
    end

    @game = Game.find(session[:game_id])
    @player = @game.players.find_by(id: session[:player_id])

    if @game.active?
      render @game.view_template(session)
    else
      redirect_to games_path
    end
  end

  def join
    game = Game.find_active(params[:code].downcase)

    unless game
      redirect_to games_path, flash: { danger: "There is no active game with code '#{params[:code].upcase}'" }
      return
    end

    game.leave_previous_game(session, cookies)
    game.join_game(params, session, cookies)
    redirect_to game_path(game)
  rescue Player::ExistingPlayerError => e
    redirect_to games_path, flash: { danger: e.message }
  end

  def leave
    Game.leave_game(session, cookies)
    redirect_to games_path
  end

  def ended
    game = Game.find(params[:id])

    if game.active?
      redirect_to game_path(game)
    else
      Game.clear_game(session, cookies)
      redirect_to games_path, flash: { info: "The game has ended" }
    end
  end
end
