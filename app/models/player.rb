# frozen_string_literal: true

class Player < ApplicationRecord
  belongs_to :game
  validates :name, presence: true

  class ExistingPlayerError < StandardError
  end
end
