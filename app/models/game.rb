# frozen_string_literal: true

class Game < ApplicationRecord
  before_create :create_code
  has_many :players

  def self.start_game(session)
    return unless session[:game_id]
    return unless session[:role] == "creator"
    game = active.find_by(id: session[:game_id])
    game.start
    game
  end

  def self.leave_game(session, cookies)
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

    clear_game(session, cookies)
  end

  def self.clear_game(session, cookies)
    session.delete(:game_id)
    session.delete(:role)
    session.delete(:player_id)
    cookies.delete(:game_id)
    cookies.delete(:role)
    cookies.delete(:player_id)
  end

  def self.find_active(code)
    active.find_by(code: code)
  end

  def self.active
    where(finished: false)
  end

  def self.generate!(session, cookies)
    transaction do
      Game.create!
    end.tap do |game|
      session[:game_id] = game.id
      session[:role] = "creator"
      cookies.permanent.signed[:game_id] = game.id
      cookies.permanent.signed[:role] = "creator"
    end
  end

  def view_template(session)
    case session[:role]
    when "creator"
      "games/for_creator"
    when "player"
      "games/for_player"
    end
  end

  def leave_previous_game(session, cookies)
    return if session[:game_id] == id
    Game.leave_game(session, cookies)
  end

  def join_game(params, session, cookies)
    create_player(params[:name]).tap do |player|
      CreatorChannel.broadcast_to(self, event: "player_joined", player: player)
      session[:game_id] = id
      session[:role] = "player"
      session[:player_id] = player.id
      cookies.permanent.signed[:game_id] = id
      cookies.permanent.signed[:role] = "player"
      cookies.permanent.signed[:player_id] = player.id
    end
  end

  def start
    self.started = true
    self.started_at = Time.zone.now
    save!
    CreatorChannel.broadcast_to(self, event: "game_started", game: self)
  end

  def terminate
    self.finished = true
    self.finished_at = Time.zone.now
    save!
    PlayerChannel.broadcast_to(self, event: "game_ended", game: self)
  end

  def active?
    !finished
  end

  private

  def create_player(name)
    name = name.strip.downcase.gsub(/\s+/, " ")
    existing = players.find_by(name: name)

    if existing && !existing.active?
      existing.reactivate
      existing
    elsif existing
      raise Player::ExistingPlayerError, "Please pick a unique name, '#{name.upcase}' is already playing!"
    else
      players.create!(name: name)
    end
  end

  def create_code
    loop do
      code = GameCode.random
      continue if Game.active.find_by(code: code)
      self.code = code
      return
    end
  end
end
