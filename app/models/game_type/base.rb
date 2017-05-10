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

    def self.random_new_round_data(game, amount)
      already_chosen_ids = game.rounds.where(game_type: game_type).pluck(:round_data_id)
      RoundData.where(game_type: game_type).where.not(id: already_chosen_ids).order("RANDOM()").take(amount)
    end

    def initialize(round)
      @round = round
    end

    def game
      round.game
    end

    def rounds
      # NOTE: The order won't necessarily be the order they are played in
      @rounds ||= game.rounds.not_finished.order(:id)
    end

    def player_state_from_boolean(test)
      if test
        "ready"
      else
        "pending"
      end
    end

    def pending?
      round.state == "pending"
    end

    def finished?
      round.state == "finished"
    end
  end
end
