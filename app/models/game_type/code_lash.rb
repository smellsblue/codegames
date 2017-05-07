module GameType
  class CodeLash < GameType::Base
    def self.game_type
      "codelash"
    end

    def self.create(game, params)
      active_players = game.players.active.to_a
      player_pairs = pair_players(active_players)
      questions = select_questions(game, player_pairs.size)

      create_rounds(game, player_pairs.size) do |round, i|
        round.round_data = questions.shift
        round.data = {
          player_pairs: player_pairs.shift,
          answers: [nil, nil],
          votes: {}
        }
      end
    end

    def self.pair_players(active_players)
      players_for_rounds_1 = active_players.dup.shuffle
      players_for_rounds_2 = active_players.dup.shuffle

      # For odd number of players, the last of the first batch will be paired
      # with the last of the second batch, so ensure they aren't the same player
      if players_for_rounds_1.last == players_for_rounds_2.first
        players_for_rounds_2.push players_for_rounds_2.shift
      end

      players_for_rounds = players_for_rounds_1 + players_for_rounds_2

      [].tap do |result|
        players_for_rounds.each_slice(2) do |pair|
          result << pair.map(&:id)
        end
      end
    end

    def self.select_questions(game, amount)
      already_chosen_ids = game.rounds.where(game_type: game_type).pluck(:round_data_id)
      RoundData.where(game_type: game_type).where.not(id: already_chosen_ids).order("RANDOM()").take(amount)
    end
  end
end