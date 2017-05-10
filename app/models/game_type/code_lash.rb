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
          votes: {},
          scoring: []
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
      random_new_round_data(game, amount)
    end

    def voting?
      game.current_round.state == "voting"
    end

    def voted?
      game.current_round.state == "voted"
    end

    def answer(player, params)
      if pending?
        provide_answer(player, params)
      elsif voting?
        vote_for_answer(player, params)
      end
    end

    def finish(params)
      round.state = "finished"
      round.save!
      next_round = round.next_round
      game.current_round = next_round
      game.save!
      active_players = game.players.active.to_a

      if next_round
        active_players.each do |player|
          PlayerChannel.broadcast_to(player, event: "round_event", round_event: "voting", round: next_round.player_channel_data(player))
        end
      else
        PlayerChannel.broadcast_to(game, event: "round_ended")
      end
    end

    def player_state(player)
      if pending?
        player_state_from_boolean(questions_for_player(player).all? { |x| x[:answer] })
      elsif voting?
        player_state_from_boolean round.data[:votes].include?(player.id)
      else
        "none"
      end
    end

    def data_for_player(player)
      if pending?
        {
          questions: questions_for_player(player)
        }
      elsif voting? || voted?
        round.data
      end
    end

    def round_data_for_player(player)
      if pending?
        {}
      elsif voting? || voted?
        round.round_data.data
      end
    end

    private

    def provide_answer(player, params)
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
          PlayerChannel.broadcast_to(player, event: "round_event", round_event: "voting", round: game.current_round.player_channel_data(player))
        end
      else
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "answer_submitted", players: game.players.active)
      end
    end

    def all_answered?
      rounds.all? do |round|
        round.data[:answers].none?(&:nil?)
      end
    end

    def vote_for_answer(player, params)
      raise "Invalid round!" if round != game.current_round
      raise "No action for this player!" if round.data[:players].include?(player.id)
      return if round.data[:votes][player.id]
      raise "Invalid vote!" unless [0, 1].include?(params[:vote].to_i)
      round.data[:votes][player.id] = params[:vote].to_i
      round.save!

      if all_voted?
        round.state = "voted"
        score_round
        round.save!
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "voted", round: round)
      else
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "vote_submitted", players: game.players.active)
      end
    end

    def score_round
      total_votes = round.data[:votes].size

      player_0_votes = round.data[:votes].values.count(0)
      player_1_votes = round.data[:votes].values.count(1)

      player_0 = game.players.find(round.data[:players][0])
      player_1 = game.players.find(round.data[:players][1])

      score_player(0, player_0, player_0_votes, total_votes, player_1_votes == 0)
      score_player(1, player_1, player_1_votes, total_votes, player_0_votes == 0)
    end

    def score_player(index, player, votes, total_votes, codelash)
      if total_votes == 0
        round.data[:scoring] << { player: index, score: 0, type: "normal" }
        return
      end

      score = (200 * (votes.to_f / total_votes.to_f)).to_i
      round.data[:scoring] << { player: index, score: score, type: "normal" }

      if codelash
        score += 100
        round.data[:scoring] << { player: index, score: 100, type: "codelash" }
      end

      player.score += score
      player.save!
    end

    def all_voted?
      game.players.active.all? do |player|
        round.data[:votes][player.id] || round.data[:players].include?(player.id)
      end
    end

    def questions_for_player(player)
      questions_by_player_id[player.id]
    end

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
