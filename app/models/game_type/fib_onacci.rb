module GameType
  class FibOnacci < GameType::Base
    SCORE_FOR_CORRECT = 200
    SCORE_PER_GUESS = 10

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
          answers: Array.new(players.size),
          answer_index_order: (-1...players.size).to_a.shuffle,
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

    def guessing?
      round.state == "guessing"
    end

    def answer(player, params)
      if pending?
        provide_answer(player, params)
      elsif guessing?
        make_guess(player, params)
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
          PlayerChannel.broadcast_to(player, event: "round_started", round: next_round.player_channel_data(player))
        end
      else
        PlayerChannel.broadcast_to(game, event: "round_ended")
      end
    end

    def player_state(player)
      if pending?
        player_state_from_boolean(answering_question?(player) && !need_answer?(player))
      elsif guessing?
        player_state_from_boolean guessed?(player)
      else
        "none"
      end
    end

    def data_for_player(player)
      if pending?
        {
          need_answer: need_answer?(player)
        }
      elsif guessing?
        {
          need_answer: !guessed?(player),
          answers: questions_for_player(player)
        }
      end
    end

    def round_data_for_player(player)
      if pending? || guessing?
        { question: round.round_data.data[:question] }
      else
        {}
      end
    end

    private

    def questions_for_player(player)
      round.data[:answer_index_order].map do |index|
        if index == -1
          { text: round.round_data.data[:answer], mine: false }
        else
          { text: round.data[:answers][index], mine: (round.data[:players][index] == player.id) }
        end
      end
    end

    def answering_question?(player)
      round.data[:players].index(player.id)
    end

    def need_answer?(player)
      index = round.data[:players].index(player.id)
      !!(index && !round.data[:answers][index])
    end

    def guessed?(player)
      !!round.data[:guesses][player.id]
    end

    def provide_answer(player, params)
      index = round.data[:players].index(player.id)
      raise "No action for this player!" unless index
      return if round.data[:answers][index]
      raise DisplayError, "That's correct! Please submit a different answer." if correct_answer?(params[:answer])
      raise DisplayError, "Someone already provided that! Please submit a different answer." if round.data[:answers].any? { |x| same_answer?(x, params[:answer]) }
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

    def correct_answer?(answer)
      same_answer?(answer, round.round_data.data[:answer])
    end

    def same_answer?(x, y)
      return false if x.nil? || y.nil?
      x.strip.downcase.gsub(/\s+/, " ") == y.strip.downcase.gsub(/\s+/, " ")
    end

    def make_guess(player, params)
      guess = params[:guess].to_i
      guess = round.data[:answer_index_order][guess]
      raise "Invalid guess!" if guess < -1 || guess >= round.data[:players].size
      raise "Cannot guess your own!" if guess != -1 && player.id == round.data[:players][guess]
      round.data[:guesses][player.id] = guess
      round.save!

      if all_guessed?
        round.state = "guessed"
        score_round
        round.save!
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "guessed", round: round)
      else
        CreatorChannel.broadcast_to(game, event: "round_event", round_event: "guess_submitted", players: game.players.active)
      end
    end

    def score_round
      round_players = round.data[:players].map { |id| game.players.find(id) }
      player_scores = {}

      round.data[:guesses].each do |player, guess|
        if guess == -1
          player_scores[player] ||= 0
          player_scores[player] += SCORE_FOR_CORRECT
          round.data[:scoring] << { player: player, score: SCORE_FOR_CORRECT, type: "correct" }
        else
          guess_for = round.data[:players][guess]
          player_scores[guess_for] ||= 0
          player_scores[guess_for] += SCORE_PER_GUESS
          round.data[:scoring] << { player: guess_for, score: SCORE_PER_GUESS, type: "guess" }
        end
      end

      round_players.each.with_index do |player, index|
        if player_scores[player.id]
          player.score += player_scores[player.id]
          player.save!
        end
      end
    end

    def all_answered?
      round.data[:answers].none?(&:nil?)
    end

    def all_guessed?
      game.players.active.all? do |player|
        round.data[:guesses].include?(player.id)
      end
    end
  end
end
