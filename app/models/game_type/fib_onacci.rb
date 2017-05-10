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

    def answer(player, params)
      if pending?
        provide_answer(player, params)
      end
    end

    def finish(params)
    end

    def player_state(player)
      if pending?
        if answering_question?(player) && !need_answer?(player)
          "ready"
        else
          "pending"
        end
      else
        "none"
      end
    end

    def data_for_player(player)
      if pending?
        {
          need_answer: need_answer?(player)
        }
      else
        {}
      end
    end

    def round_data_for_player(player)
      if pending?
        { question: round.round_data.data[:question] }
      else
        {}
      end
    end

    private

    def answering_question?(player)
      round.data[:players].index(player.id)
    end

    def need_answer?(player)
      index = round.data[:players].index(player.id)
      !!(index && !round.data[:answers][index])
    end

    def provide_answer(player, params)
      index = round.data[:players].index(player.id)
      raise "No action for this player!" unless index
      return if round.data[:answers][index]
      round.data[:answers][index] = params[:answer]
      round.save!

      if all_answered?
        round.state = "guessing"
        round.save!
        active_players = game.players.active.to_a
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "guessing", round: round, players: active_players)

        active_players.each do |player|
          PlayerChannel.broadcast_to(player, event: "round_event", round_event: "guessing", round: round.player_channel_data(player))
        end
      else
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "answer_submitted", players: game.players.active)
      end
    end

    def all_answered?
      round.data[:answers].none?(&:nil?)
    end
  end
end
