module GameType
  class FibOnacci < GameType::Base
    def self.game_type
      "fibonacci"
    end

    def self.create(game, params)
      active_players = game.players.active.to_a
      player_groups = group_players(active_players)
      questions = select_questions(game, player_groups.size)

      create_rounds(game, player_groups.size) do |round, i|
        round.round_data = questions.shift
        players = player_groups.shift

        round.data = {
          players: players,
          answers: players.map { nil },
          guesses: {},
          scoring: []
        }
      end
    end

    # Group players into sizes of 4 - 8 (or less if there are less than 4 total)
    def self.group_players(active_players)
      active_players = active_players.shuffle

      if active_players.size <= 8
        return [active_players.map(&:id)]
      end

      size = active_players.size
      remaining = 8 + (size % 8)
      remaining += 8 if remaining % 8 == 0

      active_players.map.with_index { |p, i| { id: p.id, index: i } }.group_by do |obj|
        if obj[:index] >= size - (remaining / 2)
          -1
        elsif obj[:index] >= size - remaining
          -2
        else
          obj[:index] / 8
        end
      end.values.map { |array| array.map { |obj| obj[:id] } }
    end

    def self.select_questions(game, amount)
      random_new_round_data(game, amount)
    end
  end
end
