class FibOnacci
    constructor: (round) ->
        @round = round

    needAnswer: ->
        @round.data.need_answer

    answerAtIndex: (index) ->
        if index == -1
            @round.roundData.answer
        else
            @round.data.answers[index]

    render: ->
        if Game.role == "creator"
            @renderForCreator()
        else
            @renderForPlayer()

    renderForCreator: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-pending", @round)
            when "guessing"
                $("#game-content").html tmpl("tmpl-fibonacci-guessing", @round)

    renderForPlayer: ->
        switch @round.state
            when "pending"
                $("#game-content").html tmpl("tmpl-fibonacci-question", @round)
            when "guessing"
                $("#game-content").html tmpl("tmpl-fibonacci-guessing", @round)

    updatePlayerStates: (players) ->
        return unless Game.role == "creator"

        for player in players
            Player.find(player.id).setRoundState(player.round_state)

    renderNewRound: (data) ->
        Round.current = new Round(data)
        Round.current.render()

    onEvent: (data) ->
        switch data.round_event
            when "answer_submitted"
                @updatePlayerStates(data.players)
            when "guess_submitted"
                @updatePlayerStates(data.players)
            when "guessing"
                @renderNewRound(data)
                @updatePlayerStates(data.players)

window.GameType.FibOnacci = FibOnacci
