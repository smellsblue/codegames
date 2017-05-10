class FibOnacci
    constructor: (round) ->
        @round = round

    needAnswer: ->
        true

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

    onEvent: (data) ->
        switch data.round_event
            when "answer_submitted"
                console.log "not yet"

window.GameType.FibOnacci = FibOnacci
