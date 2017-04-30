# frozen_string_literal: true

class Game < ApplicationRecord
  before_create :create_code

  def self.active
    where(finished: false)
  end

  def self.with_code(code)
    where(code: code)
  end

  def self.generate!
    transaction do
      Game.create!
    end
  end

  def active?
    !finished
  end

  private

  def create_code
    loop do
      code = GameCode.random
      continue if Game.active.with_code(code).first
      self.code = code
      return
    end
  end
end
