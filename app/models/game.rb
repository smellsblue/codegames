# frozen_string_literal: true

class Game < ApplicationRecord
  before_create :create_code

  def self.leave_game(session)
    return unless session[:game_id]
    game = active.find_by(id: session[:game_id])
    return unless game

    case session[:role]
    when "creator"
      game.terminate
    when "player"
      player = game.players.find(session[:player_id])
      player.leave_game
    end

    session.delete(:game_id)
    session.delete(:role)
    session.delete(:player_id)
  end

  def self.find_active(code)
    active.find_by(code: code)
  end

  def self.active
    where(finished: false)
  end

  def self.generate!(session)
    transaction do
      Game.create!
    end.tap do |game|
      session[:game_id] = game.id
      session[:role] = "creator"
    end
  end

  def leave_previous_game(session)
    return unless session[:game_id] != id
    Game.leave_game(session)
  end

  def terminate
    self.finished = true
    self.finished_at = Time.zone.now
    save!
  end

  def active?
    !finished
  end

  private

  def create_code
    loop do
      code = GameCode.random
      continue if Game.active.find_by(code: code)
      self.code = code
      return
    end
  end
end
