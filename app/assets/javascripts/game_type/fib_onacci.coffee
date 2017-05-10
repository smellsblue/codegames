class FibOnacci
    constructor: (round) ->
        @round = round

    needAnswer: ->
        @round.data.need_answer

    render: ->
        if Game.role == "creator"
            @renderForCreator()
        else
            @renderForPlayer()

    renderForCreator: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-pending", @round)

    renderForPlayer: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-question", @round)

    updatePlayerStates: (players) ->
        return unless Game.role == "creator"

        for player in players
            Player.find(player.id).setRoundState(player.round_state)

    onEvent: (data) ->
        switch data.round_event
            when "answer_submitted"
                @updatePlayerStates(data.players)

window.GameType.FibOnacci = FibOnacci
