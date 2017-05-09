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
          players: player_pairs.shift,
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

    def voting?
      game.current_round.state == "voting"
    end

    def answer(player, params)
      if pending?
        index = round.data[:players].index(player.id)
        raise "No action for this player!" unless index
        return if round.data[:answers][index]
        round.data[:answers][index] = params[:answer]
        round.save!

        if all_answered?
          rounds.update_all(state: "voting")
          active_players = game.players.active.to_a
          CreatorChannel.broadcast_to(game, event: "round_event", round_event: "voting", round: game.current_round, players: active_players)

          active_players.each do |player|
            PlayerChannel.broadcast_to(player, event: "round_event", round_event: "vote", round: game.current_round.player_channel_data(player))
          end
        else
          CreatorChannel.broadcast_to(game, event: "round_event", round_event: "answer_submitted", players: game.players.active)
        end
      end
    end

    def all_answered?
      rounds.all? do |round|
        round.data[:answers].none?(&:nil?)
      end
    end

    def player_state(player)
      if pending?
        questions = questions_for_player(player)

        if questions.all? { |x| x[:answer] }
          "ready"
        else
          "pending"
        end
      end
    end

    def questions_for_player(player)
      questions_by_player_id[player.id]
    end

    def data_for_player(player)
      if pending?
        {
          questions: questions_for_player(player)
        }
      elsif voting?
        round.data
      end
    end

    def round_data_for_player(player)
      if pending?
        {}
      elsif voting?
        round.round_data.data
      end
    end

    private

    def questions_by_player_id
      @questions_by_player_id ||= {}.tap do |result|
        rounds.each do |round|
          result[round.data[:players].first] ||= []
          result[round.data[:players].last] ||= []

          result[round.data[:players].first] << {
            round_id: round.id,
            text: round.round_data.data[:question],
            answer: round.data[:answers].first
          }

          result[round.data[:players].last] << {
            round_id: round.id,
            text: round.round_data.data[:question],
            answer: round.data[:answers].last
          }
        end
      end
    end
  end
end
