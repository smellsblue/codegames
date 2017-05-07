module GameType
  class Base
    attr_reader :round

    def self.create_rounds(game, amount)
      first_round = nil
      previous_round = nil

      amount.times do |i|
        round = game.rounds.build(game_type: game_type, state: "pending")
        previous_round.next_round = round if previous_round
        previous_round = round
        first_round = round unless first_round
        yield(round, i)
      end

      first_round
    end

    def initialize(round)
      @round = round
    end
  end
end
