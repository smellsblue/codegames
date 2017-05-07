class Round < ApplicationRecord
  belongs_to :game
  belongs_to :round_data
  belongs_to :next_round, class_name: "Round", optional: true
  serialize :data

  # Create a round, which could end up being multiple rounds, and start the
  # first round
  def self.start_round(game, params)
    next_round =
      transaction do
        round = GameType.game_class(params[:game]).create(game, params)
        game.current_round = round
        # This will save all the rounds being created also
        game.save!
        round
      end

    next_round.broadcast_data
    next_round
  end

  def game_object
    @game_object ||= GameType.game_class(game_type).new(self)
  end

  def broadcast_data
    CreatorChannel.broadcast_to(game, event: "round_started", round: creator_channel_data)

    game.players.active.each do |player|
      PlayerChannel.broadcast_to(player, event: "round_started", round: player_channel_data(player))
    end
  end

  def to_json_for_player(player)
    player_channel_data(player).to_json
  end

  def creator_channel_data
    {}
  end

  def player_channel_data(player)
    {
      id: id,
      game_type: game_type,
      state: state,
      data: game_object.data_for_player(player)
    }
  end
end
